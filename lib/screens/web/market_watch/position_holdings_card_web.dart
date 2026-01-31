import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import '../../../models/order_book_model/order_book_model.dart';
import '../../../res/res.dart';
import '../../../models/portfolio_model/holdings_model.dart';
import '../../../models/portfolio_model/position_book_model.dart';
import '../../../provider/market_watch_provider.dart';
import '../../../provider/order_provider.dart';
import '../../../provider/portfolio_provider.dart';
import '../../../provider/thems.dart';
import '../../../provider/websocket_provider.dart';
import '../../../res/mynt_web_color_styles.dart';
import '../../../res/mynt_web_text_styles.dart';
import '../../../sharedWidget/common_buttons_web.dart';
import '../../../utils/responsive_navigation.dart';
import 'package:mynt_plus/sharedWidget/snack_bar.dart';
import '../order/modify_place_order_web_screen.dart';
import 'tv_chart/chart_iframe_guard.dart';

/// A card that displays position or holdings information for the current symbol
/// at the top of the depth screen. Shows P&L, quantity, and exit buttons.
class PositionHoldingsCardWeb extends ConsumerStatefulWidget {
  final String token;
  final String exchange;
  final String tsym;

  const PositionHoldingsCardWeb({
    super.key,
    required this.token,
    required this.exchange,
    required this.tsym,
  });

  @override
  ConsumerState<PositionHoldingsCardWeb> createState() =>
      _PositionHoldingsCardWebState();
}

class _PositionHoldingsCardWebState
    extends ConsumerState<PositionHoldingsCardWeb> {
  @override
  Widget build(BuildContext context) {
    final portfolio = ref.watch(portfolioProviderRef);
    final socketDatas = ref.watch(websocketProvider).socketDatas;
    final theme = ref.read(themeProvider);
    final orderProv = ref.watch(orderProvider);

    // Find position for this token
    final position = _findPositionByToken(portfolio, widget.token);
    // Find holding for this token
    final holding = _findHoldingByToken(portfolio, widget.token);
    // Find open orders for this token
    final openOrders = _findOpenOrdersByToken(orderProv, widget.token);

    // If neither position nor holding nor orders exist, return empty
    if (position == null && holding == null && openOrders.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        // Position card (if exists)
        if (position != null)
          _buildPositionCard(position, socketDatas, theme),

        // Holdings card (if exists)
        if (holding != null) _buildHoldingsCard(holding, socketDatas, theme),

        // Open orders section (if any)
        if (openOrders.isNotEmpty)
          _buildOpenOrdersSection(openOrders, socketDatas, theme),
      ],
    );
  }

  /// Find position by token from the position book
  PositionBookModel? _findPositionByToken(
      PortfolioProvider provider, String token) {
    final positions = provider.postionBookModel ?? [];
    for (final pos in positions) {
      if (pos.token == token) {
        return pos;
      }
    }
    return null;
  }

  /// Find holding by token from the holdings list
  HoldingsModel? _findHoldingByToken(
      PortfolioProvider provider, String token) {
    final holdings = provider.holdingsModel ?? [];
    for (final hold in holdings) {
      if (hold.exchTsym != null && hold.exchTsym!.isNotEmpty) {
        final holdToken = hold.exchTsym![0].token;
        if (holdToken == token) {
          return hold;
        }
      }
    }
    return null;
  }

  /// Find open orders for this token
  List<OrderBookModel> _findOpenOrdersByToken(
      OrderProvider provider, String token) {
    final openOrders = provider.openOrder ?? [];
    return openOrders.where((order) => order.token == token).toList();
  }

  /// Get fresh LTP from WebSocket data
  double _getFreshLtp(Map socketDatas, String? token, String? fallbackLtp) {
    if (token == null) return double.tryParse(fallbackLtp ?? '0') ?? 0;

    final socketData = socketDatas[token];
    if (socketData != null && socketData['lp'] != null) {
      return double.tryParse(socketData['lp'].toString()) ?? 0;
    }
    return double.tryParse(fallbackLtp ?? '0') ?? 0;
  }

  /// Calculate P&L percentage for position
  double _calculatePnlPercent(
      double ltp, double avgPrice, bool isLong, double pnl) {
    if (avgPrice == 0) return 0;

    // Calculate percentage based on price movement
    // For long: profit when ltp > avgPrice
    // For short: profit when ltp < avgPrice
    if (isLong) {
      return ((ltp - avgPrice) / avgPrice) * 100;
    } else {
      return ((avgPrice - ltp) / avgPrice) * 100;
    }
  }

  Widget _buildPositionCard(
      PositionBookModel position, Map socketDatas, ThemesProvider theme) {
    final ltp = _getFreshLtp(socketDatas, position.token, position.lp);
    final avgPrice = double.tryParse(position.avgPrc ?? '0') ?? 0;
    // Use netqty to determine long/short
    final netQty = int.tryParse(position.netqty ?? '0') ?? 0;
    // For MCX, divide quantity by lot size
    final lotSize = position.exch == 'MCX'
        ? (int.tryParse(position.ls ?? '1') ?? 1)
        : 1;
    final absQty = (netQty.abs()) ~/ lotSize;

    // Use pre-calculated P&L from provider (accounts for lot size, multiplier, etc.)
    final pnl = double.tryParse(position.profitNloss ?? '0') ?? 0;
    final isProfit = pnl >= 0;

    // Determine if it's a long or short position based on netqty
    final isLong = netQty > 0;
    final positionType = isLong ? "LONG" : "SHORT";

    // Calculate P&L percentage based on price movement
    final pnlPercent = _calculatePnlPercent(ltp, avgPrice, isLong, pnl);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: shadcn.Theme.of(context).colorScheme.card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isProfit
              ? resolveThemeColor(context,
                      dark: MyntColors.profitDark, light: MyntColors.profit)
                  .withValues(alpha: 0.3)
              : resolveThemeColor(context,
                      dark: MyntColors.lossDark, light: MyntColors.loss)
                  .withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row: Position label + Product type
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: isLong
                          ? resolveThemeColor(context,
                                  dark: MyntColors.primaryDark,
                                  light: MyntColors.primary)
                              .withValues(alpha: 0.15)
                          : resolveThemeColor(context,
                                  dark: MyntColors.tertiary,
                                  light: MyntColors.tertiary)
                              .withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      positionType,
                      style: MyntWebTextStyles.para(
                        context,
                        fontWeight: MyntFonts.semiBold,
                        color: isLong
                            ? resolveThemeColor(context,
                                dark: MyntColors.primaryDark,
                                light: MyntColors.primary)
                            : resolveThemeColor(context,
                                dark: MyntColors.tertiary,
                                light: MyntColors.tertiary),
                      ),
                    ),
                  ),
                ],
              ),
              // Product type badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: resolveThemeColor(context,
                          dark: MyntColors.searchBgDark,
                          light: MyntColors.searchBg)
                      .withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  position.sPrdtAli ?? position.prd ?? '',
                  style: MyntWebTextStyles.para(
                    context,
                    fontWeight: MyntFonts.medium,
                    color: resolveThemeColor(context,
                        dark: MyntColors.textSecondaryDark,
                        light: MyntColors.textSecondary),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Main content row: Qty + Avg + LTP | P&L
          Row(
            children: [
              // Left side: Qty, Avg, LTP
              Expanded(
                flex: 2,
                child: Row(
                  children: [
                    _buildInfoColumn("Qty", "$absQty"),
                    const SizedBox(width: 16),
                    _buildInfoColumn("Avg", avgPrice.toStringAsFixed(2)),
                    const SizedBox(width: 16),
                    _buildInfoColumn("LTP", ltp.toStringAsFixed(2)),
                  ],
                ),
              ),
              // Right side: P&L
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "${isProfit ? '+' : ''}${pnl.toStringAsFixed(2)}",
                      style: MyntWebTextStyles.price(
                        context,
                        fontWeight: MyntFonts.semiBold,
                        color: isProfit
                            ? resolveThemeColor(context,
                                dark: MyntColors.profitDark,
                                light: MyntColors.profit)
                            : resolveThemeColor(context,
                                dark: MyntColors.lossDark,
                                light: MyntColors.loss),
                      ),
                    ),
                    Text(
                      "(${pnlPercent >= 0 ? '+' : ''}${pnlPercent.toStringAsFixed(2)}%)",
                      style: MyntWebTextStyles.para(
                        context,
                        fontWeight: MyntFonts.medium,
                        color: isProfit
                            ? resolveThemeColor(context,
                                dark: MyntColors.profitDark,
                                light: MyntColors.profit)
                            : resolveThemeColor(context,
                                dark: MyntColors.lossDark,
                                light: MyntColors.loss),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Exit button
          SizedBox(
            width: double.infinity,
            height: 36,
            child: MyntButton(
              label: "Exit Position",
              size: MyntButtonSize.small,
              backgroundColor: isLong
                  ? resolveThemeColor(context,
                      dark: MyntColors.tertiary, light: MyntColors.tertiary)
                  : resolveThemeColor(context,
                      dark: MyntColors.primary, light: MyntColors.primary),
              textColor: Colors.white,
              onPressed: () => _exitPosition(position, ltp),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHoldingsCard(
      HoldingsModel holding, Map socketDatas, ThemesProvider theme) {
    // Get the exchange tsym that matches our token
    ExchTsym? matchingExch;
    for (final exch in holding.exchTsym ?? []) {
      if (exch.token == widget.token) {
        matchingExch = exch;
        break;
      }
    }

    if (matchingExch == null) return const SizedBox.shrink();

    final ltp =
        _getFreshLtp(socketDatas, matchingExch.token, matchingExch.lp);
    final avgPrice = double.tryParse(holding.avgPrc ?? '0') ?? 0;
    // Use currentQty for display (total holdings), saleableQty is for selling
    final currentQty = holding.currentQty ?? 0;
    final saleableQty = holding.saleableQty ?? 0;

    // Show card if there's any holding (currentQty > 0)
    if (currentQty <= 0) return const SizedBox.shrink();

    // Use pre-calculated P&L from provider (more accurate)
    final pnl = double.tryParse(matchingExch.profitNloss ?? '0') ?? 0;
    final pnlPercent = double.tryParse(matchingExch.pNlChng ?? '0') ?? 0;
    final isProfit = pnl >= 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: shadcn.Theme.of(context).colorScheme.card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isProfit
              ? resolveThemeColor(context,
                      dark: MyntColors.profitDark, light: MyntColors.profit)
                  .withValues(alpha: 0.3)
              : resolveThemeColor(context,
                      dark: MyntColors.lossDark, light: MyntColors.loss)
                  .withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row: Holdings label + Product type
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: resolveThemeColor(context,
                              dark: MyntColors.primaryDark,
                              light: MyntColors.primary)
                          .withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      "HOLDING",
                      style: MyntWebTextStyles.para(
                        context,
                        fontWeight: MyntFonts.semiBold,
                        color: resolveThemeColor(context,
                            dark: MyntColors.primaryDark,
                            light: MyntColors.primary),
                      ),
                    ),
                  ),
                ],
              ),
              // CNC badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: resolveThemeColor(context,
                          dark: MyntColors.searchBgDark,
                          light: MyntColors.searchBg)
                      .withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  holding.sPrdtAli ?? "CNC",
                  style: MyntWebTextStyles.para(
                    context,
                    fontWeight: MyntFonts.medium,
                    color: resolveThemeColor(context,
                        dark: MyntColors.textSecondaryDark,
                        light: MyntColors.textSecondary),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Main content row: Qty + Avg + LTP | P&L
          Row(
            children: [
              // Left side: Qty, Avg, LTP
              Expanded(
                flex: 2,
                child: Row(
                  children: [
                    _buildInfoColumn("Qty", "$currentQty"),
                    const SizedBox(width: 16),
                    _buildInfoColumn("Avg", avgPrice.toStringAsFixed(2)),
                    const SizedBox(width: 16),
                    _buildInfoColumn("LTP", ltp.toStringAsFixed(2)),
                  ],
                ),
              ),
              // Right side: P&L
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "${isProfit ? '+' : ''}${pnl.toStringAsFixed(2)}",
                      style: MyntWebTextStyles.price(
                        context,
                        fontWeight: MyntFonts.semiBold,
                        color: isProfit
                            ? resolveThemeColor(context,
                                dark: MyntColors.profitDark,
                                light: MyntColors.profit)
                            : resolveThemeColor(context,
                                dark: MyntColors.lossDark,
                                light: MyntColors.loss),
                      ),
                    ),
                    Text(
                      "(${isProfit ? '+' : ''}${pnlPercent.toStringAsFixed(2)}%)",
                      style: MyntWebTextStyles.para(
                        context,
                        fontWeight: MyntFonts.medium,
                        color: isProfit
                            ? resolveThemeColor(context,
                                dark: MyntColors.profitDark,
                                light: MyntColors.profit)
                            : resolveThemeColor(context,
                                dark: MyntColors.lossDark,
                                light: MyntColors.loss),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Sell button
          SizedBox(
            width: double.infinity,
            height: 36,
            child: MyntButton(
              label: "Sell Holdings",
              size: MyntButtonSize.small,
              backgroundColor: resolveThemeColor(context,
                  dark: MyntColors.tertiary, light: MyntColors.tertiary),
              textColor: Colors.white,
              onPressed: () => _exitHolding(holding, matchingExch!, ltp, saleableQty),
            ),
          ),
        ],
      ),
    );
  }

  /// Build open orders section showing pending orders for this symbol
  Widget _buildOpenOrdersSection(
      List<OrderBookModel> orders, Map socketDatas, ThemesProvider theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: shadcn.Theme.of(context).colorScheme.card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: resolveThemeColor(context,
                  dark: MyntColors.warning, light: MyntColors.warning)
              .withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Open Orders label
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: resolveThemeColor(context,
                          dark: MyntColors.warning,
                          light: MyntColors.warning)
                      .withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  "OPEN ORDERS",
                  style: MyntWebTextStyles.para(
                    context,
                    fontWeight: MyntFonts.semiBold,
                    color: resolveThemeColor(context,
                        dark: MyntColors.warning,
                        light: MyntColors.warning),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "${orders.length}",
                style: MyntWebTextStyles.para(
                  context,
                  fontWeight: MyntFonts.medium,
                  color: resolveThemeColor(context,
                      dark: MyntColors.textSecondaryDark,
                      light: MyntColors.textSecondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // List of orders
          ...orders.map((order) => _buildOrderRow(order, socketDatas, theme)),
        ],
      ),
    );
  }

  /// Build individual order row with cancel/edit buttons
  Widget _buildOrderRow(
      OrderBookModel order, Map socketDatas, ThemesProvider theme) {
    final isBuy = order.trantype == "B";
    // For MCX, divide quantity by lot size
    final rawQty = int.tryParse(order.qty ?? "0") ?? 0;
    final lotSize = order.exch == 'MCX'
        ? (int.tryParse(order.ls ?? '1') ?? 1)
        : 1;
    final qty = (rawQty ~/ lotSize).toString();
    final price = order.prc ?? "0";
    final triggerPrice = order.trgprc ?? "";
    final priceType = order.prctyp ?? "";
    final product = order.sPrdtAli ?? order.prd ?? "";

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: resolveThemeColor(context,
                dark: MyntColors.backgroundColorDark,
                light: MyntColors.backgroundColor)
            .withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isBuy
              ? resolveThemeColor(context,
                      dark: MyntColors.primaryDark, light: MyntColors.primary)
                  .withValues(alpha: 0.2)
              : resolveThemeColor(context,
                      dark: MyntColors.tertiary, light: MyntColors.tertiary)
                  .withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Buy/Sell indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: isBuy
                  ? resolveThemeColor(context,
                          dark: MyntColors.primaryDark,
                          light: MyntColors.primary)
                      .withValues(alpha: 0.15)
                  : resolveThemeColor(context,
                          dark: MyntColors.tertiary, light: MyntColors.tertiary)
                      .withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              isBuy ? "BUY" : "SELL",
              style: MyntWebTextStyles.para(
                context,
                fontWeight: MyntFonts.semiBold,
                color: isBuy
                    ? resolveThemeColor(context,
                        dark: MyntColors.primaryDark, light: MyntColors.primary)
                    : resolveThemeColor(context,
                        dark: MyntColors.tertiary, light: MyntColors.tertiary),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Order details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      "Qty: $qty",
                      style: MyntWebTextStyles.para(
                        context,
                        fontWeight: MyntFonts.medium,
                        color: resolveThemeColor(context,
                            dark: MyntColors.textPrimaryDark,
                            light: MyntColors.textPrimary),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "@ $price",
                      style: MyntWebTextStyles.para(
                        context,
                        fontWeight: MyntFonts.medium,
                        color: resolveThemeColor(context,
                            dark: MyntColors.textPrimaryDark,
                            light: MyntColors.textPrimary),
                      ),
                    ),
                    if (triggerPrice.isNotEmpty && triggerPrice != "0.00") ...[
                      const SizedBox(width: 12),
                      Text(
                        "Trg: $triggerPrice",
                        style: MyntWebTextStyles.para(
                          context,
                          fontWeight: MyntFonts.medium,
                          color: resolveThemeColor(context,
                              dark: MyntColors.textSecondaryDark,
                              light: MyntColors.textSecondary),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      priceType,
                      style: MyntWebTextStyles.para(
                        context,
                        fontWeight: MyntFonts.regular,
                        color: resolveThemeColor(context,
                            dark: MyntColors.textSecondaryDark,
                            light: MyntColors.textSecondary),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      product,
                      style: MyntWebTextStyles.para(
                        context,
                        fontWeight: MyntFonts.regular,
                        color: resolveThemeColor(context,
                            dark: MyntColors.textSecondaryDark,
                            light: MyntColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Action buttons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Edit button
              IconButton(
                onPressed: () => _modifyOrder(order),
                icon: Icon(
                  Icons.edit_outlined,
                  size: 18,
                  color: resolveThemeColor(context,
                      dark: MyntColors.primaryDark, light: MyntColors.primary),
                ),
                tooltip: "Modify Order",
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
              const SizedBox(width: 4),
              // Cancel button
              IconButton(
                onPressed: () => _cancelOrder(order),
                icon: Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: resolveThemeColor(context,
                      dark: MyntColors.lossDark, light: MyntColors.loss),
                ),
                tooltip: "Cancel Order",
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: MyntWebTextStyles.para(
            context,
            fontWeight: MyntFonts.medium,
            color: resolveThemeColor(context,
                dark: MyntColors.textSecondaryDark,
                light: MyntColors.textSecondary),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: MyntWebTextStyles.body(
            context,
            fontWeight: MyntFonts.medium,
            color: resolveThemeColor(context,
                dark: MyntColors.textPrimaryDark,
                light: MyntColors.textPrimary),
          ),
        ),
      ],
    );
  }

  Future<void> _exitPosition(PositionBookModel position, double ltp) async {
    final netQty = int.tryParse(position.netqty ?? '0') ?? 0;

    // Fetch scrip info for order
    await ref.read(marketWatchProvider).fetchScripInfo(
          widget.token,
          widget.exchange,
          context,
          true,
        );

    final scripInfo = ref.read(marketWatchProvider).scripInfoModel;
    if (scripInfo == null) return;

    // For long position, we sell; for short position, we buy
    final orderArgs = OrderScreenArgs(
      exchange: widget.exchange,
      tSym: widget.tsym,
      isExit: true,
      token: widget.token,
      transType: netQty < 0 ? true : false, // Buy if short, Sell if long
      prd: position.prd ?? "",
      lotSize: position.ls ?? "1",
      ltp: ltp.toStringAsFixed(2),
      perChange: position.perChange ?? "0.00",
      orderTpye: '',
      holdQty: netQty.abs().toString(),
      isModify: false,
      raw: {},
    );

    ResponsiveNavigation.toPlaceOrderScreen(
      context: context,
      arguments: {
        "orderArg": orderArgs,
        "scripInfo": scripInfo,
        "isBskt": "",
      },
    );
  }

  Future<void> _exitHolding(
      HoldingsModel holding, ExchTsym exchTsym, double ltp, int saleableQty) async {
    // Check if there's sellable quantity available
    if (saleableQty <= 0) {
      // Show error message like holdings page does
      showResponsiveErrorMessage(
        context,
        "No sellable quantity available. Shares may be pledged, under delivery, or used as collateral.",
      );
      return;
    }

    // Fetch scrip info for order
    await ref.read(marketWatchProvider).fetchScripInfo(
          widget.token,
          widget.exchange,
          context,
          true,
        );

    final scripInfo = ref.read(marketWatchProvider).scripInfoModel;
    if (scripInfo == null) return;

    // For holdings, we always sell
    final orderArgs = OrderScreenArgs(
      exchange: widget.exchange,
      tSym: widget.tsym,
      isExit: true,
      token: widget.token,
      transType: false, // Sell
      prd: holding.prd ?? "C", // CNC for holdings
      lotSize: exchTsym.ls ?? "1",
      ltp: ltp.toStringAsFixed(2),
      perChange: exchTsym.perChange ?? "0.00",
      orderTpye: '',
      holdQty: saleableQty.toString(),
      isModify: false,
      raw: {},
    );

    ResponsiveNavigation.toPlaceOrderScreen(
      context: context,
      arguments: {
        "orderArg": orderArgs,
        "scripInfo": scripInfo,
        "isBskt": "",
      },
    );
  }

  /// Disable all chart iframes to allow pointer events on dialog
  void _disableAllChartIframes() {
    if (!kIsWeb) return;
    try {
      final iframes = html.document.querySelectorAll('iframe');
      for (var iframe in iframes) {
        if (iframe is html.IFrameElement && iframe.id.contains('chart-iframe')) {
          iframe.style.pointerEvents = 'none';
        }
      }
      html.document.body?.style.cursor = 'default';
    } catch (e) {
      debugPrint('Error disabling iframes: $e');
    }
  }

  /// Enable all chart iframes after dialog is closed
  void _enableAllChartIframes() {
    if (!kIsWeb) return;
    try {
      final iframes = html.document.querySelectorAll('iframe');
      for (var iframe in iframes) {
        if (iframe is html.IFrameElement && iframe.id.contains('chart-iframe')) {
          iframe.style.pointerEvents = 'auto';
        }
      }
    } catch (e) {
      debugPrint('Error enabling iframes: $e');
    }
  }

  /// Cancel an open order
  Future<void> _cancelOrder(OrderBookModel order) async {
    final symbol = order.tsym?.replaceAll("-EQ", "") ?? 'N/A';

    // Show confirmation dialog with iframe handling (same style as orders screen)
    final shouldCancel = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return PointerInterceptor(
          child: MouseRegion(
            cursor: SystemMouseCursors.basic,
            onEnter: (_) {
              ChartIframeGuard.acquire();
              _disableAllChartIframes();
            },
            onHover: (_) {
              _disableAllChartIframes();
            },
            onExit: (_) {
              ChartIframeGuard.release();
              _enableAllChartIframes();
            },
            child: Listener(
              onPointerMove: (_) {
                _disableAllChartIframes();
              },
              child: Dialog(
                backgroundColor: Colors.transparent,
                child: Container(
                  width: 400,
                  decoration: BoxDecoration(
                    color: resolveThemeColor(context,
                        dark: colors.colorBlack, light: colors.colorWhite),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header row with title and close button
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 16),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: resolveThemeColor(
                                context,
                                dark: MyntColors.dividerDark,
                                light: MyntColors.divider,
                              ),
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Cancel Order',
                              style: MyntWebTextStyles.title(
                                context,
                                color: resolveThemeColor(context,
                                    dark: MyntColors.textPrimaryDark,
                                    light: MyntColors.textPrimary),
                              ),
                            ),
                            Material(
                              color: Colors.transparent,
                              shape: const CircleBorder(),
                              child: InkWell(
                                customBorder: const CircleBorder(),
                                onTap: () {
                                  ChartIframeGuard.release();
                                  _enableAllChartIframes();
                                  Navigator.of(dialogContext).pop(false);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Icon(
                                    Icons.close,
                                    size: 20,
                                    color: resolveThemeColor(context,
                                        dark: MyntColors.textSecondaryDark,
                                        light: MyntColors.textSecondary),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Content area
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            // Confirmation text with symbol in quotes
                            Text(
                              'Are you sure you want to cancel "$symbol"?',
                              textAlign: TextAlign.center,
                              style: MyntWebTextStyles.body(
                                context,
                                color: resolveThemeColor(context,
                                    dark: MyntColors.textPrimaryDark,
                                    light: MyntColors.textPrimary),
                              ),
                            ),

                            // Red Cancel button
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              height: 44,
                              child: TextButton(
                                onPressed: () {
                                  ChartIframeGuard.release();
                                  _enableAllChartIframes();
                                  Navigator.of(dialogContext).pop(true);
                                },
                                style: TextButton.styleFrom(
                                  backgroundColor: MyntColors.tertiary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                                child: Text(
                                  'Cancel',
                                  style: MyntWebTextStyles.buttonMd(
                                    context,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    // Ensure iframes are re-enabled after dialog closes
    ChartIframeGuard.release();
    _enableAllChartIframes();

    if (shouldCancel != true || !mounted) return;

    // Cancel the order
    await ref.read(orderProvider).fetchOrderCancel(
          "${order.norenordno}",
          context,
          true,
        );
  }

  /// Modify an open order
  Future<void> _modifyOrder(OrderBookModel order) async {
    // Fetch scrip info for order
    await ref.read(marketWatchProvider).fetchScripInfo(
          order.token ?? widget.token,
          order.exch ?? widget.exchange,
          context,
          true,
        );

    final scripInfo = ref.read(marketWatchProvider).scripInfoModel;
    if (scripInfo == null) {
      showResponsiveErrorMessage(context, "Unable to fetch scrip information");
      return;
    }

    // Create order args for modify
    final orderArgs = OrderScreenArgs(
      exchange: order.exch ?? widget.exchange,
      tSym: order.tsym ?? widget.tsym,
      isExit: false,
      token: order.token ?? widget.token,
      transType: order.trantype == "B",
      prd: order.prd ?? "",
      lotSize: order.ls ?? "1",
      ltp: order.ltp ?? "0.00",
      perChange: order.perChange ?? "0.00",
      orderTpye: order.prctyp ?? "",
      holdQty: order.qty ?? "",
      isModify: true,
      raw: order.toJson(),
    );

    // Show modify dialog
    ModifyPlaceOrderScreenWeb.showDraggable(
      context: context,
      modifyOrderArgs: order,
      scripInfo: scripInfo,
      orderArg: orderArgs,
      initialPosition: Offset(
        MediaQuery.of(context).size.width / 2 - 200,
        MediaQuery.of(context).size.height / 2 - 200,
      ),
    );
  }
}

/// Provider ref alias for cleaner code
final portfolioProviderRef = portfolioProvider;
