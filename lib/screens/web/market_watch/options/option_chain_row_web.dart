/// PERFORMANCE OPTIMIZED: Single virtualized row containing [Call | Strike | Put]
/// This widget is used with ListView.builder to achieve lazy loading of option chain rows.
/// Only visible rows (~20) are built at a time instead of all 200+.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';
import '../../../../models/marketwatch_model/get_quotes.dart';
import '../../../../models/marketwatch_model/opt_chain_model.dart';
import '../../../../models/order_book_model/order_book_model.dart';
import '../../../../provider/market_watch_provider.dart';
import '../../../../provider/order_provider.dart';
import '../../../../provider/thems.dart';
import '../../../../provider/websocket_provider.dart';
// import '../../../../res/res.dart'; // Unused - hover disabled for test
import '../../../../res/web_colors.dart';
import '../../../../res/global_font_web.dart';
import '../../../../sharedWidget/snack_bar.dart';
import '../../../../utils/responsive_navigation.dart';
import '../../../../utils/responsive_snackbar.dart';

/// Data class representing a single strike price row
class StrikeRowData {
  final String strikePrice;
  final bool isATM;
  final OptionValues? callOption;
  final OptionValues? putOption;

  const StrikeRowData({
    required this.strikePrice,
    required this.isATM,
    this.callOption,
    this.putOption,
  });
}

/// Combined option chain row widget for virtualization
/// Contains [Call Cell | Strike Price | Put Cell] in a single row
class OptionChainRowWeb extends ConsumerStatefulWidget {
  final StrikeRowData rowData;
  final Set<String> watchlistTokens;
  final bool showPriceView;
  final bool isBasketMode;
  final SwipeActionController? swipeController;
  final int index;
  final GlobalKey? atmKey; // Key to mark ATM row for scrolling

  const OptionChainRowWeb({
    super.key,
    required this.rowData,
    required this.watchlistTokens,
    required this.showPriceView,
    required this.isBasketMode,
    this.swipeController,
    required this.index,
    this.atmKey,
  });

  @override
  ConsumerState<OptionChainRowWeb> createState() => _OptionChainRowWebState();
}

class _OptionChainRowWebState extends ConsumerState<OptionChainRowWeb> {
  // PERFORMANCE: Use ValueNotifier for hover - no setState rebuilds
  final _isCallHovered = ValueNotifier<bool>(false);
  final _isPutHovered = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _isCallHovered.dispose();
    _isPutHovered.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.read(themeProvider);

    // PERFORMANCE FIX: Each row watches ONLY its own token with .select()
    // When token A updates, only row A rebuilds - NOT all 200+ rows!
    // This replaces the 500ms timer that caused 100% CPU with 120 full rebuilds/min
    final callSocketData = widget.rowData.callOption != null
        ? ref.watch(websocketProvider.select((p) => p.socketDatas[widget.rowData.callOption!.token]))
        : null;
    final putSocketData = widget.rowData.putOption != null
        ? ref.watch(websocketProvider.select((p) => p.socketDatas[widget.rowData.putOption!.token]))
        : null;

    // ATM row highlight
    final isATM = widget.rowData.isATM;
    final atmColor = isATM
        ? (theme.isDarkMode ? WebDarkColors.primary : WebColors.primary).withOpacity(0.08)
        : Colors.transparent;

    return RepaintBoundary(
      key: widget.atmKey,
      child: Container(
        height: 40,
        color: atmColor,
        child: Row(
          children: [
            // CALL cell (flex: 6)
            Expanded(
              flex: 6,
              child: _buildCallCell(callSocketData, theme),
            ),
            // STRIKE price cell (fixed width: 150)
            _buildStrikeCell(theme),
            // PUT cell (flex: 6)
            Expanded(
              flex: 6,
              child: _buildPutCell(putSocketData, theme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCallCell(Map<String, dynamic>? socketData, ThemesProvider theme) {
    final option = widget.rowData.callOption;
    if (option == null) {
      return const SizedBox.shrink();
    }

    // Calculate values from websocket data (with fallbacks)
    final lp = socketData?['lp']?.toString() ?? option.lp ?? option.close ?? "0.00";
    final perChange = socketData?['pc']?.toString() ?? option.perChange ?? "0.00";
    final currentOI = double.tryParse(socketData?['oi']?.toString() ?? option.oi ?? "0") ?? 0.0;
    final oiLack = (currentOI / 100000).toStringAsFixed(2);

    // Calculate OI percentage change
    final poi = double.tryParse(socketData?['poi']?.toString() ?? "0") ?? 0.0;
    String oiPerChng = "0.00";
    if (poi > 0) {
      oiPerChng = (((currentOI - poi) / poi) * 100).toStringAsFixed(2);
    } else if (currentOI > 0) {
      oiPerChng = "100.00";
    }

    final changeColor = perChange.startsWith("-")
        ? (theme.isDarkMode ? WebDarkColors.loss : WebColors.loss)
        : (perChange == "0.00" || perChange == "0.0"
            ? (theme.isDarkMode ? WebDarkColors.textSecondary : WebColors.textSecondary)
            : (theme.isDarkMode ? WebDarkColors.profit : WebColors.profit));

    // Check watchlist status
    final scripToken = "${option.exch}|${option.token}";
    final isInWatchlist = widget.watchlistTokens.contains(scripToken);

    // PERFORMANCE: MouseRegion for hover, ValueListenableBuilder for minimal rebuilds
    return MouseRegion(
      onEnter: (_) => _isCallHovered.value = true,
      onExit: (_) => _isCallHovered.value = false,
      child: GestureDetector(
        onTap: () => _handleCellTap(option, true),
        child: ValueListenableBuilder<bool>(
          valueListenable: _isCallHovered,
          builder: (context, isHovered, child) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              color: isHovered
                  ? (theme.isDarkMode ? WebDarkColors.primary : WebColors.primary).withOpacity(0.15)
                  : Colors.transparent,
              child: Stack(
                children: [
                  // Data row - CALLS: OI% | OI | CH% | LTP
                  Row(
                    children: [
                      // OI% column
                      Expanded(
                        child: Text(
                          "${oiPerChng == "NaN" ? "0.00" : oiPerChng}%",
                          style: WebTextStyles.tableDataCompact(
                            isDarkTheme: theme.isDarkMode,
                            color: (oiPerChng.startsWith("-"))
                                ? (theme.isDarkMode ? WebDarkColors.loss : WebColors.loss)
                                : (theme.isDarkMode ? WebDarkColors.profit : WebColors.profit),
                          ),
                        ),
                      ),
                      // OI column
                      Expanded(
                        child: Text(
                          oiLack,
                          style: WebTextStyles.tableDataCompact(
                            isDarkTheme: theme.isDarkMode,
                            color: theme.isDarkMode ? WebDarkColors.textPrimary : WebColors.textPrimary,
                          ),
                        ),
                      ),
                      // CH% column
                      Expanded(
                        child: Text(
                          "$perChange%",
                          style: WebTextStyles.tableDataCompact(
                            isDarkTheme: theme.isDarkMode,
                            color: changeColor,
                          ),
                        ),
                      ),
                      // LTP column
                      Expanded(
                        child: Text(
                          lp,
                          style: WebTextStyles.tableDataCompact(
                            isDarkTheme: theme.isDarkMode,
                            color: theme.isDarkMode ? WebDarkColors.textPrimary : WebColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Hover buttons - positioned at right
                  if (isHovered)
                    Positioned(
                      top: 0,
                      bottom: 0,
                      right: 0,
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildHoverButton(
                              label: 'B',
                              color: Colors.white,
                              backgroundColor: theme.isDarkMode ? WebDarkColors.primary : WebColors.primary,
                              onPressed: () => _placeOrder(option, true),
                              theme: theme,
                            ),
                            const SizedBox(width: 4),
                            _buildHoverButton(
                              label: 'S',
                              color: Colors.white,
                              backgroundColor: theme.isDarkMode ? WebDarkColors.tertiary : WebColors.tertiary,
                              onPressed: () => _placeOrder(option, false),
                              theme: theme,
                            ),
                            const SizedBox(width: 4),
                            _buildHoverButton(
                              icon: Icons.bar_chart,
                              color: Colors.black,
                              backgroundColor: Colors.white,
                              onPressed: () => _handleChartTap(option),
                              theme: theme,
                            ),
                            const SizedBox(width: 4),
                            _buildHoverButton(
                              icon: isInWatchlist ? Icons.bookmark : Icons.bookmark_border,
                              color: isInWatchlist
                                  ? (theme.isDarkMode ? WebDarkColors.primary : WebColors.primary)
                                  : (theme.isDarkMode ? WebDarkColors.textSecondary : WebColors.textSecondary),
                              backgroundColor: Colors.white,
                              onPressed: () => _handleSaveToWatchlist(option),
                              theme: theme,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStrikeCell(ThemesProvider theme) {
    final isATM = widget.rowData.isATM;

    return SizedBox(
      width: 150,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isATM
              ? (theme.isDarkMode ? WebDarkColors.primary : WebColors.primary).withOpacity(0.15)
              : Colors.transparent,
          border: Border.symmetric(
            vertical: BorderSide(
              color: theme.isDarkMode ? WebDarkColors.divider : WebColors.divider,
              width: 0.5,
            ),
          ),
        ),
        child: Text(
          widget.rowData.strikePrice,
          style: WebTextStyles.tableDataCompact(
            isDarkTheme: theme.isDarkMode,
            color: isATM
                ? (theme.isDarkMode ? WebDarkColors.primary : WebColors.primary)
                : (theme.isDarkMode ? WebDarkColors.textPrimary : WebColors.textPrimary),
          ).copyWith(fontWeight: isATM ? FontWeight.w600 : FontWeight.w400),
        ),
      ),
    );
  }

  Widget _buildPutCell(Map<String, dynamic>? socketData, ThemesProvider theme) {
    final option = widget.rowData.putOption;
    if (option == null) {
      return const SizedBox.shrink();
    }

    // Calculate values from websocket data (with fallbacks)
    final lp = socketData?['lp']?.toString() ?? option.lp ?? option.close ?? "0.00";
    final perChange = socketData?['pc']?.toString() ?? option.perChange ?? "0.00";
    final currentOI = double.tryParse(socketData?['oi']?.toString() ?? option.oi ?? "0") ?? 0.0;
    final oiLack = (currentOI / 100000).toStringAsFixed(2);

    // Calculate OI percentage change
    final poi = double.tryParse(socketData?['poi']?.toString() ?? "0") ?? 0.0;
    String oiPerChng = "0.00";
    if (poi > 0) {
      oiPerChng = (((currentOI - poi) / poi) * 100).toStringAsFixed(2);
    } else if (currentOI > 0) {
      oiPerChng = "100.00";
    }

    final changeColor = perChange.startsWith("-")
        ? (theme.isDarkMode ? WebDarkColors.loss : WebColors.loss)
        : (perChange == "0.00" || perChange == "0.0"
            ? (theme.isDarkMode ? WebDarkColors.textSecondary : WebColors.textSecondary)
            : (theme.isDarkMode ? WebDarkColors.profit : WebColors.profit));

    // Check watchlist status
    final scripToken = "${option.exch}|${option.token}";
    final isInWatchlist = widget.watchlistTokens.contains(scripToken);

    // PERFORMANCE: MouseRegion for hover, ValueListenableBuilder for minimal rebuilds
    return MouseRegion(
      onEnter: (_) => _isPutHovered.value = true,
      onExit: (_) => _isPutHovered.value = false,
      child: GestureDetector(
        onTap: () => _handleCellTap(option, false),
        child: ValueListenableBuilder<bool>(
          valueListenable: _isPutHovered,
          builder: (context, isHovered, child) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              color: isHovered
                  ? (theme.isDarkMode ? WebDarkColors.primary : WebColors.primary).withOpacity(0.15)
                  : Colors.transparent,
              child: Stack(
                children: [
                  // Data row - PUTS: LTP | CH% | OI | OI%
                  Row(
                    children: [
                      // LTP column
                      Expanded(
                        child: Text(
                          lp,
                          style: WebTextStyles.tableDataCompact(
                            isDarkTheme: theme.isDarkMode,
                            color: theme.isDarkMode ? WebDarkColors.textPrimary : WebColors.textPrimary,
                          ),
                        ),
                      ),
                      // CH% column
                      Expanded(
                        child: Text(
                          "$perChange%",
                          style: WebTextStyles.tableDataCompact(
                            isDarkTheme: theme.isDarkMode,
                            color: changeColor,
                          ),
                        ),
                      ),
                      // OI column
                      Expanded(
                        child: Text(
                          oiLack,
                          style: WebTextStyles.tableDataCompact(
                            isDarkTheme: theme.isDarkMode,
                            color: theme.isDarkMode ? WebDarkColors.textPrimary : WebColors.textPrimary,
                          ),
                        ),
                      ),
                      // OI% column
                      Expanded(
                        child: Text(
                          "${oiPerChng == "NaN" ? "0.00" : oiPerChng}%",
                          style: WebTextStyles.tableDataCompact(
                            isDarkTheme: theme.isDarkMode,
                            color: (oiPerChng.startsWith("-"))
                                ? (theme.isDarkMode ? WebDarkColors.loss : WebColors.loss)
                                : (theme.isDarkMode ? WebDarkColors.profit : WebColors.profit),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Hover buttons - positioned at left (for PUT side)
                  if (isHovered)
                    Positioned(
                      top: 0,
                      bottom: 0,
                      left: 0,
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildHoverButton(
                              label: 'S',
                              color: Colors.white,
                              backgroundColor: theme.isDarkMode ? WebDarkColors.tertiary : WebColors.tertiary,
                              onPressed: () => _placeOrder(option, false),
                              theme: theme,
                            ),
                            const SizedBox(width: 4),
                            _buildHoverButton(
                              label: 'B',
                              color: Colors.white,
                              backgroundColor: theme.isDarkMode ? WebDarkColors.primary : WebColors.primary,
                              onPressed: () => _placeOrder(option, true),
                              theme: theme,
                            ),
                            const SizedBox(width: 4),
                            _buildHoverButton(
                              icon: Icons.bar_chart,
                              color: Colors.black,
                              backgroundColor: Colors.white,
                              onPressed: () => _handleChartTap(option),
                              theme: theme,
                            ),
                            const SizedBox(width: 4),
                            _buildHoverButton(
                              icon: isInWatchlist ? Icons.bookmark : Icons.bookmark_border,
                              color: isInWatchlist
                                  ? (theme.isDarkMode ? WebDarkColors.primary : WebColors.primary)
                                  : (theme.isDarkMode ? WebDarkColors.textSecondary : WebColors.textSecondary),
                              backgroundColor: Colors.white,
                              onPressed: () => _handleSaveToWatchlist(option),
                              theme: theme,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHoverButton({
    String? label,
    IconData? icon,
    String? svgIcon,
    required Color color,
    Color? backgroundColor,
    required VoidCallback? onPressed,
    required ThemesProvider theme,
  }) {
    return SizedBox(
      width: 25,
      height: 25,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(5.0),
          splashColor: color.withOpacity(0.15),
          highlightColor: color.withOpacity(0.08),
          onTap: onPressed,
          child: Container(
            decoration: BoxDecoration(
              color: backgroundColor ?? Colors.transparent,
              borderRadius: BorderRadius.circular(5.0),
            ),
            child: Center(
              child: svgIcon != null
                  ? SvgPicture.asset(
                      svgIcon,
                      height: 16,
                      width: 16,
                      color: color,
                    )
                  : icon != null
                      ? Icon(icon, size: 16, color: color)
                      : Text(
                          label ?? "",
                          style: WebTextStyles.buttonXs(
                            isDarkTheme: theme.isDarkMode,
                            color: color,
                          ),
                        ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleCellTap(OptionValues option, bool isCall) {
    if (option.tsym?.contains("|||") ?? false) {
      showResponsiveWarningMessage(context, "Symbol not available for trading");
      return;
    }

    if (widget.isBasketMode) {
      _handleBasketModeTap(option);
    } else {
      _handleTap(option, isCall);
    }
  }

  void _handleTap(OptionValues option, bool isCall) async {
    final scripData = ref.read(marketWatchProvider);

    await scripData.fetchScripQuoteIndex(
      "${option.token}",
      "${option.exch}",
      context,
    );
    final quots = scripData.getQuotes;
    if (quots != null) {
      DepthInputArgs depthArgs = DepthInputArgs(
        exch: quots.exch.toString(),
        token: quots.token.toString(),
        tsym: quots.tsym.toString(),
        instname: quots.instname.toString(),
        symbol: quots.symbol.toString(),
        expDate: quots.expDate.toString(),
        option: quots.option.toString(),
      );
      scripData.scripdepthsize(false);
      await scripData.calldepthApis(context, depthArgs, "");
    }
  }

  Future<void> _handleBasketModeTap(OptionValues option) async {
    final scripData = ref.read(marketWatchProvider);
    final orderProv = ref.read(orderProvider);

    // Check if a basket is selected
    if (orderProv.selectedBsktName.isEmpty) {
      showResponsiveErrorMessage(context, "Please select a basket");
      return;
    }

    // Preserve current symbol context before basket operations
    scripData.preserveContextForBasket();

    await scripData.fetchScripQuoteIndex(
      "${option.token}",
      "${option.exch}",
      context,
    );
    final quots = scripData.getQuotes;

    if (quots != null) {
      DepthInputArgs depthArgs = DepthInputArgs(
        exch: quots.exch.toString(),
        token: quots.token.toString(),
        tsym: quots.tsym.toString(),
        instname: quots.instname.toString(),
        symbol: quots.symbol.toString(),
        expDate: quots.expDate.toString(),
        option: quots.option.toString(),
      );

      await scripData.calldepthApis(context, depthArgs, "BasketMode");

      // Restore original symbol context after basket operations
      scripData.restoreContextFromBasket();
    }
  }

  Future<void> _placeOrder(OptionValues option, bool isBuy) async {
    final scripData = ref.read(marketWatchProvider);

    await scripData.fetchScripInfo(
      option.token.toString(),
      option.exch.toString(),
      context,
      true,
    );

    // Use lot size from scripInfoModel if option data doesn't have it
    final lotSize = option.ls?.isNotEmpty == true
        ? option.ls
        : scripData.scripInfoModel?.ls.toString();

    OrderScreenArgs orderArgs = OrderScreenArgs(
      exchange: option.exch.toString(),
      tSym: option.tsym.toString(),
      isExit: false,
      token: option.token.toString(),
      transType: isBuy,
      lotSize: lotSize,
      ltp: "${option.lp ?? option.close ?? 0.00}",
      perChange: option.perChange ?? "0.00",
      orderTpye: '',
      holdQty: '',
      isModify: false,
      raw: {},
    );

    ResponsiveNavigation.toPlaceOrderScreen(
      context: context,
      arguments: {
        "orderArg": orderArgs,
        "scripInfo": scripData.scripInfoModel!,
        "isBskt": "",
      },
    );
  }

  Future<void> _handleChartTap(OptionValues option) async {
    final scripData = ref.read(marketWatchProvider);

    await scripData.fetchScripQuoteIndex(
      "${option.token}",
      "${option.exch}",
      context,
    );
    final quots = scripData.getQuotes;
    if (quots != null) {
      DepthInputArgs depthArgs = DepthInputArgs(
        exch: quots.exch.toString(),
        token: quots.token.toString(),
        tsym: quots.tsym.toString(),
        instname: quots.instname.toString(),
        symbol: quots.symbol.toString(),
        expDate: quots.expDate.toString(),
        option: quots.option.toString(),
      );
      scripData.scripdepthsize(false);
      await scripData.calldepthApis(context, depthArgs, "");
    }
  }

  Future<void> _handleSaveToWatchlist(OptionValues option) async {
    final scripData = ref.read(marketWatchProvider);

    if (scripData.isPreDefWLs == "Yes") {
      showResponsiveWarningMessage(context, "This is a pre-defined watchlist that cannot be edited!");
      return;
    }

    final scripToken = "${option.exch}|${option.token}";
    final isCurrentlyInWatchlist = scripData.scrips.any((scrip) =>
        "${scrip['exch']}|${scrip['token']}" == scripToken
    );

    if (isCurrentlyInWatchlist) {
      // Delete from watchlist
      final success = await scripData.addDelMarketScrip(
        scripData.wlName,
        scripToken,
        context,
        false, // delete
        true,
        false,
        false, // Set isOptionStike to false to prevent provider's Fluttertoast
      );
      if (success && mounted) {
        ResponsiveSnackBar.showInfo(context, 'Removed from ${scripData.wlName}');
      }
    } else {
      // Add to watchlist - establish websocket connection first
      ref.read(websocketProvider).establishConnection(
        channelInput: scripToken,
        task: "t",
        context: context,
      );

      final success = await scripData.addDelMarketScrip(
        scripData.wlName,
        scripToken,
        context,
        true, // add
        true,
        false,
        false, // Set isOptionStike to false to prevent provider's Fluttertoast
      );
      if (success && mounted) {
        ResponsiveSnackBar.showSuccess(context, 'Added to ${scripData.wlName}');
      }
    }
  }
}
