import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../../../../models/order_book_model/order_book_model.dart';
import '../../../../provider/market_watch_provider.dart';
import '../../../../provider/order_provider.dart';
import '../../../../provider/thems.dart';
import '../../../../provider/websocket_provider.dart';
import '../../../../res/res.dart';
import '../../../../res/mynt_web_text_styles.dart';
import '../../../../res/mynt_web_color_styles.dart';
import '../../../../sharedWidget/functions.dart';
import '../../../../sharedWidget/snack_bar.dart';
import '../../../../sharedWidget/mynt_loader.dart';
import '../../../../sharedWidget/list_divider.dart';
import '../../../../utils/responsive_navigation.dart';
import '../../ordersbook/basket/create_basket_web.dart';

/// A sidebar widget for basket management in option chain.
/// Appears on the right side when basket mode is enabled.
class BasketSidebarWeb extends ConsumerStatefulWidget {
  final VoidCallback onClose;

  /// Static width of the sidebar
  static const double sidebarWidth = 360;

  const BasketSidebarWeb({
    super.key,
    required this.onClose,
  });

  @override
  ConsumerState<BasketSidebarWeb> createState() => _BasketSidebarWebState();
}

class _BasketSidebarWebState extends ConsumerState<BasketSidebarWeb> {
  @override
  void initState() {
    super.initState();
    // Ensure WebSocket subscriptions are established
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ensureBasketWebSocketSubscription();
    });
  }

  void _ensureBasketWebSocketSubscription() async {
    final orderProv = ref.read(orderProvider);
    if (orderProv.selectedBsktName.isNotEmpty &&
        orderProv.bsktScripList.isNotEmpty) {
      await orderProv.chngBsktName(orderProv.selectedBsktName, context, true);
      if (kDebugMode) {
        print(
            "WebSocket subscription refreshed for basket: ${orderProv.selectedBsktName}");
      }
    }
  }

  /// Checks if the basket contains scripts from multiple exchanges
  bool _hasMultipleExchanges(List scriptList) {
    if (scriptList.isEmpty) return false;
    Set<String> exchanges = {};
    for (var script in scriptList) {
      if (script['exch'] != null) {
        exchanges.add(script['exch'].toString());
      }
    }
    return exchanges.length > 1;
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final orderProv = ref.watch(orderProvider);
    // Watch WebSocket data to get fresh LTP for basket items
    final socketDatas = ref.watch(websocketProvider).socketDatas;

    // Sidebar content with static width
    return Container(
      width: BasketSidebarWeb.sidebarWidth,
      decoration: BoxDecoration(
        color: resolveThemeColor(context,
            dark: MyntColors.backgroundColorDark,
            light: MyntColors.backgroundColor),
        border: Border(
          left: BorderSide(
            color: shadcn.Theme.of(context).colorScheme.border,
          ),
        ),
      ),
      child: Column(
        children: [
          // Header
          _buildHeader(theme, orderProv),
          const ListDivider(),

          // Margins section
          if (orderProv.selectedBsktName.isNotEmpty &&
              orderProv.bsktScripList.isNotEmpty)
            _buildMarginsSection(theme, orderProv),

          // Content
          orderProv.bsktList.isEmpty
              ? _buildCreateBasketView(theme, orderProv)
              : _buildBasketContent(theme, orderProv, socketDatas),

          // Multi-exchange warning
          if (orderProv.bsktScripList.isNotEmpty &&
              _hasMultipleExchanges(orderProv.bsktScripList))
            _buildMultiExchangeWarning(),

          // Place Order Button
          if (orderProv.selectedBsktName.isNotEmpty &&
              orderProv.bsktScripList.isNotEmpty)
            _buildPlaceOrderButton(theme, orderProv),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemesProvider theme, OrderProvider orderProv) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 8, top: 12, bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  orderProv.selectedBsktName.isNotEmpty
                      ? orderProv.selectedBsktName
                      : "No Basket Selected",
                  style: MyntWebTextStyles.title(context,
                      fontWeight: MyntFonts.semiBold,
                      color: resolveThemeColor(
                        context,
                        dark: MyntColors.textPrimaryDark,
                        light: MyntColors.textPrimary,
                      )),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                if (orderProv.selectedBsktName.isNotEmpty)
                  Text(
                    "${orderProv.bsktScripList.length} items",
                    style: MyntWebTextStyles.body(
                      context,
                      color: resolveThemeColor(
                        context,
                        dark: MyntColors.textSecondaryDark,
                        light: MyntColors.textSecondary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Switch basket icon
              if (orderProv.bsktList.length > 1)
                _buildIconButton(
                  icon: Icons.swap_horiz,
                  tooltip: "Switch Basket",
                  onTap: () => _showBasketSelector(context),
                ),

              // Refresh margin icon
              if (orderProv.selectedBsktName.isNotEmpty &&
                  orderProv.bsktScripList.isNotEmpty)
                _buildIconButton(
                  icon: Icons.refresh,
                  tooltip: "Refresh Margin",
                  onTap: () => orderProv.fetchBasketMargin(),
                ),

              // Add basket icon
              _buildIconButton(
                icon: Icons.add_circle_outline,
                tooltip: "Create Basket",
                onTap: () => _showCreateBasket(context),
              ),

              // Close sidebar icon
              _buildIconButton(
                icon: Icons.close,
                tooltip: "Close",
                onTap: widget.onClose,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: () async {
          await Future.delayed(const Duration(milliseconds: 100));
          onTap();
        },
        borderRadius: BorderRadius.circular(20),
        splashColor: resolveThemeColor(
          context,
          dark: MyntColors.rippleDark,
          light: MyntColors.rippleLight,
        ),
        highlightColor: resolveThemeColor(
          context,
          dark: MyntColors.highlightDark,
          light: MyntColors.highlightLight,
        ),
        child: Tooltip(
          message: tooltip,
          child: Padding(
            padding: const EdgeInsets.all(6.0),
            child: Icon(
              icon,
              size: 22,
              color: resolveThemeColor(
                context,
                dark: MyntColors.iconDark,
                light: MyntColors.icon,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMarginsSection(ThemesProvider theme, OrderProvider orderProv) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Pre Trade Margin",
                style: TextStyle(
                  fontFamily: 'Geist',
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: shadcn.Theme.of(context).colorScheme.mutedForeground,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                orderProv.bsktScripList.isEmpty ||
                        orderProv.bsktOrderMargin == null
                    ? "₹0.00"
                    : "₹${orderProv.bsktOrderMargin!.marginused ?? '0.00'}",
                style: TextStyle(
                  fontFamily: 'Geist',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: shadcn.Theme.of(context).colorScheme.foreground,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "Post Trade Margin",
                style: TextStyle(
                  fontFamily: 'Geist',
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: shadcn.Theme.of(context).colorScheme.mutedForeground,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                orderProv.bsktScripList.isEmpty ||
                        orderProv.bsktOrderMargin == null
                    ? "₹0.00"
                    : "₹${orderProv.bsktOrderMargin!.marginusedtrade ?? '0.00'}",
                style: TextStyle(
                  fontFamily: 'Geist',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: shadcn.Theme.of(context).colorScheme.foreground,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMultiExchangeWarning() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: resolveThemeColor(
          context,
          dark: MyntColors.lossDark,
          light: MyntColors.loss,
        ).withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: resolveThemeColor(
              context,
              dark: MyntColors.lossDark,
              light: MyntColors.loss,
            ),
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "Basket should contain orders of only 1 segment",
              style: TextStyle(
                fontFamily: 'Geist',
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: resolveThemeColor(
                  context,
                  dark: MyntColors.lossDark,
                  light: MyntColors.loss,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateBasketView(ThemesProvider theme, OrderProvider orderProvider) {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(assets.noDatafound,
                color: const Color(0xff777777), width: 48, height: 48),
            const SizedBox(height: 8),
            Text(
              "No baskets found",
              style: TextStyle(
                fontFamily: 'Geist',
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: shadcn.Theme.of(context).colorScheme.mutedForeground,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _showCreateBasket(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: resolveThemeColor(
                  context,
                  dark: MyntColors.primaryDark,
                  light: MyntColors.primary,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text(
                "Create Basket",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasketContent(ThemesProvider theme, OrderProvider orderProvider, Map socketDatas) {
    // If no basket is selected, show basket selector
    if (orderProvider.selectedBsktName.isEmpty) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                assets.noDatafound,
                color: const Color(0xff777777),
                width: 48,
                height: 48,
              ),
              const SizedBox(height: 8),
              Text(
                "No Basket Selected",
                style: TextStyle(
                  fontFamily: 'Geist',
                  fontSize: 13,
                  color: resolveThemeColor(
                    context,
                    dark: MyntColors.textSecondaryDark,
                    light: MyntColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _showBasketSelector(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: resolveThemeColor(
                    context,
                    dark: MyntColors.primary,
                    light: MyntColors.primary,
                  ),
                  minimumSize: const Size(0, 40),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                ),
                child: const Text(
                  "Choose Basket",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // If basket is selected but empty
    if (orderProvider.bsktScripList.isEmpty) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                assets.noDatafound,
                color: const Color(0xff777777),
                width: 48,
                height: 48,
              ),
              const SizedBox(height: 8),
              Text(
                "Basket is empty",
                style: TextStyle(
                  fontFamily: 'Geist',
                  fontSize: 13,
                  color: resolveThemeColor(
                    context,
                    dark: MyntColors.textSecondaryDark,
                    light: MyntColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  "Click on options to add them to basket",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Geist',
                    fontSize: 12,
                    color: resolveThemeColor(
                      context,
                      dark: MyntColors.textSecondaryDark,
                      light: MyntColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Basket items list
    return Expanded(
      child: ListView.separated(
        padding: EdgeInsets.zero,
        itemCount: orderProvider.bsktScripList.length,
        separatorBuilder: (_, __) => const ListDivider(),
        itemBuilder: (context, index) {
          final script = Map<String, dynamic>.from(orderProvider.bsktScripList[index]);

          // Process script data for display
          if (script['exch'] == "BFO" && script["dname"] != "null") {
            List<String> splitVal = script["dname"].toString().split(" ");
            script['symbol'] = splitVal[0];
            script['expDate'] = "${splitVal[1]} ${splitVal[2]}";
            script['option'] =
                splitVal.length > 4 ? "${splitVal[3]} ${splitVal[4]}" : splitVal[3];
          } else {
            Map spilitSymbol = spilitTsym(value: "${script['tsym']}");
            script['symbol'] = "${spilitSymbol["symbol"]}";
            script['expDate'] = "${spilitSymbol["expDate"]}";
            script['option'] = "${spilitSymbol["option"]}";
          }

          return _buildScriptCard(theme, script, index, orderProvider, socketDatas);
        },
      ),
    );
  }

  Widget _buildScriptCard(
      ThemesProvider theme, Map script, int index, OrderProvider orderProv, Map socketDatas) {
    // **FIX: Get fresh LTP from WebSocket data instead of stale script['lp']**
    final token = script['token']?.toString();
    final socketData = token != null ? socketDatas[token] : null;
    final freshLtp = socketData?['lp']?.toString() ?? script['lp']?.toString() ?? '0.00';
    return InkWell(
      onTap: () => _handleBasketItemTap(index, script, orderProv),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: Symbol and status/delete
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          script['symbol'].toString().replaceAll("-EQ", ""),
                          style: MyntWebTextStyles.body(context,
                              fontWeight: MyntFonts.medium,
                              color: resolveThemeColor(
                                context,
                                dark: MyntColors.textPrimaryDark,
                                light: MyntColors.textPrimary,
                              )),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        " ${script['expDate']} ${script['option']}",
                        style: MyntWebTextStyles.caption(context,
                            color: resolveThemeColor(
                              context,
                              dark: MyntColors.textSecondaryDark,
                              light: MyntColors.textSecondary,
                            )),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Status badge
                    if (script['orderStatus'] != null)
                      Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color:
                              _getItemStatusColor(script['orderStatus']).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _getItemStatusText(script['orderStatus']),
                          style: TextStyle(
                            fontFamily: 'Geist',
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: _getItemStatusColor(script['orderStatus']),
                          ),
                        ),
                      ),
                    // Delete button
                    if (script['orderStatus'] == null ||
                        !_isOrderPlaced(script['orderStatus']))
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _deleteScript(index, script, orderProv),
                          borderRadius: BorderRadius.circular(4),
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Icon(
                              Icons.delete_outline,
                              size: 18,
                              color: resolveThemeColor(
                                context,
                                dark: MyntColors.lossDark,
                                light: MyntColors.loss,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Row 2: Exchange, order type, price type, LTP
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${script["exch"]} · ${script["ordType"]} · ${script["prctype"]}",
                  style: TextStyle(
                    fontFamily: 'Geist',
                    fontSize: 11,
                    color: resolveThemeColor(
                      context,
                      dark: MyntColors.textSecondaryDark,
                      light: MyntColors.textSecondary,
                    ),
                  ),
                ),
                Text(
                  "LTP $freshLtp",
                  style: TextStyle(
                    fontFamily: 'Geist',
                    fontSize: 11,
                    color: resolveThemeColor(
                      context,
                      dark: MyntColors.textSecondaryDark,
                      light: MyntColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // Row 3: Buy/Sell, qty, price
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      script["trantype"] == "S" ? "SELL" : "BUY",
                      style: TextStyle(
                        fontFamily: 'Geist',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: script["trantype"] == "S"
                            ? resolveThemeColor(context,
                                dark: MyntColors.lossDark, light: MyntColors.loss)
                            : resolveThemeColor(context,
                                dark: MyntColors.primaryDark,
                                light: MyntColors.primary),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Qty: ${script["qty"]}",
                      style: TextStyle(
                        fontFamily: 'Geist',
                        fontSize: 11,
                        color: resolveThemeColor(
                          context,
                          dark: MyntColors.textSecondaryDark,
                          light: MyntColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                if (script["prctype"] != "MKT")
                  Text(
                    "@ ${script['prc'] ?? '0.00'}",
                    style: TextStyle(
                      fontFamily: 'Geist',
                      fontSize: 11,
                      color: resolveThemeColor(
                        context,
                        dark: MyntColors.textSecondaryDark,
                        light: MyntColors.textSecondary,
                      ),
                    ),
                  ),
              ],
            ),

            // Rejection reason
            if (script['rejectionReason'] != null &&
                script['orderStatus'] == 'failed')
              Container(
                margin: const EdgeInsets.only(top: 6),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: resolveThemeColor(
                    context,
                    dark: MyntColors.lossDark,
                    light: MyntColors.loss,
                  ).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: resolveThemeColor(
                        context,
                        dark: MyntColors.lossDark,
                        light: MyntColors.loss,
                      ),
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        script['rejectionReason'],
                        style: TextStyle(
                          fontFamily: 'Geist',
                          fontSize: 10,
                          color: resolveThemeColor(
                            context,
                            dark: MyntColors.lossDark,
                            light: MyntColors.loss,
                          ),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceOrderButton(ThemesProvider theme, OrderProvider orderProv) {
    final hasMultipleExchanges = _hasMultipleExchanges(orderProv.bsktScripList);
    final basketStatus =
        orderProv.basketOverallStatus[orderProv.selectedBsktName] ?? '';
    final isBasketPlaced = orderProv.isBasketPlaced(orderProv.selectedBsktName);

    // Show reset button if basket has been placed
    if (isBasketPlaced) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              orderProv.resetBasketOrderTracking(orderProv.selectedBsktName);
              showResponsiveSuccess(context, "Basket reset. You can place orders again.");
            },
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(0, 45),
              side: BorderSide(
                color: resolveThemeColor(
                  context,
                  dark: MyntColors.primaryDark,
                  light: MyntColors.primary,
                ),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            child: Text(
              "Reset Orders",
              style: TextStyle(
                fontFamily: 'Geist',
                fontWeight: FontWeight.w600,
                color: resolveThemeColor(
                  context,
                  dark: MyntColors.primaryDark,
                  light: MyntColors.primary,
                ),
              ),
            ),
          ),
        ),
      );
    }

    // Place order button
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        height: 45,
        child: ElevatedButton(
          onPressed: hasMultipleExchanges
              ? null
              : basketStatus == 'placing'
                  ? null
                  : () async {
                      await orderProv.placeBasketOrder(context,
                          navigateToOrderBook: false);
                    },
          style: ElevatedButton.styleFrom(
            backgroundColor: hasMultipleExchanges
                ? Colors.grey
                : resolveThemeColor(
                    context,
                    dark: MyntColors.primaryDark,
                    light: MyntColors.primary,
                  ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          child: basketStatus == 'placing'
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MyntLoader.inline(),
                    const SizedBox(width: 8),
                    const Text(
                      "Placing...",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                )
              : const Text(
                  "Place Order",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }

  // Helper methods
  Color _getItemStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'placed':
        return resolveThemeColor(context,
            dark: MyntColors.primaryDark, light: MyntColors.primary);
      case 'complete':
        return resolveThemeColor(context,
            dark: MyntColors.profitDark, light: MyntColors.profit);
      case 'rejected':
      case 'canceled':
      case 'failed':
        return resolveThemeColor(context,
            dark: MyntColors.lossDark, light: MyntColors.loss);
      case 'open':
      case 'partial':
      case 'trigger_pending':
        return resolveThemeColor(context,
            dark: MyntColors.warning, light: MyntColors.warning);
      default:
        return resolveThemeColor(context,
            dark: MyntColors.iconDark, light: MyntColors.icon);
    }
  }

  String _getItemStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'placed':
        return 'PLACED';
      case 'complete':
        return 'EXECUTED';
      case 'rejected':
        return 'REJECTED';
      case 'canceled':
        return 'CANCELLED';
      case 'failed':
        return 'FAILED';
      case 'open':
        return 'OPEN';
      case 'partial':
        return 'PARTIAL';
      case 'trigger_pending':
        return 'PENDING';
      default:
        return status.toUpperCase();
    }
  }

  bool _isOrderPlaced(String status) {
    return !['pending', 'draft', 'preparing'].contains(status.toLowerCase());
  }

  void _handleBasketItemTap(int index, Map script, OrderProvider orderProvider) {
    String? orderStatus = script['orderStatus'];
    if (orderStatus != null && _isOrderPlaced(orderStatus)) {
      // Navigate to order book if order is placed
      // _navigateToOrderBook(orderProvider, orderStatus);
    } else {
      // Edit if not placed
      _editScript(index, script, orderProvider);
    }
  }

  void _editScript(int index, Map script, OrderProvider orderProv) async {
    await ref.read(marketWatchProvider).fetchScripInfo(
          "${script['token']}",
          '${script['exch']}',
          context,
          true,
        );

    script['index'] = index;
    script['prctyp'] = script['prctype'];

    if (script['prd'] == null || script['prd'].toString().isEmpty) {
      final ordType = script['ordType']?.toString();
      if (ordType == 'MIS') {
        script['prd'] = 'I';
      } else if (ordType == 'CNC') {
        script['prd'] = 'C';
      } else if (ordType == 'NRML') {
        script['prd'] = 'M';
      }
    }

    final ltp = script['lp']?.toString() ?? "0.00";
    final perChange = script['pc']?.toString() ?? "0.00";

    OrderScreenArgs orderArgs = OrderScreenArgs(
      exchange: '${script['exch']}',
      tSym: '${script['tsym']}',
      isExit: false,
      token: "${script['token']}",
      transType: script['trantype'] == 'B' ? true : false,
      lotSize: ref.read(marketWatchProvider).scripInfoModel?.ls.toString(),
      ltp: ltp,
      perChange: perChange,
      orderTpye: '',
      holdQty: '',
      isModify: true,
      prd: script['prd']?.toString(),
      raw: script,
    );

    ResponsiveNavigation.toPlaceOrderScreen(context: context, arguments: {
      "orderArg": orderArgs,
      "scripInfo": ref.read(marketWatchProvider).scripInfoModel!,
      "isBskt": 'BasketEdit'
    });
  }

  void _deleteScript(int index, Map script, OrderProvider orderProv) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        final theme = ref.read(themeProvider);
        return AlertDialog(
          backgroundColor: theme.isDarkMode
              ? const Color(0xFF121212)
              : const Color(0xFFF1F3F8),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          contentPadding: const EdgeInsets.all(20),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.delete_outline,
                size: 48,
                color: resolveThemeColor(
                  context,
                  dark: MyntColors.lossDark,
                  light: MyntColors.loss,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Remove from basket?",
                style: TextStyle(
                  fontFamily: 'Geist',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: resolveThemeColor(
                    context,
                    dark: MyntColors.textPrimaryDark,
                    light: MyntColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "${script['symbol']?.toString().replaceAll("-EQ", "")} ${script['expDate']} ${script['option']}",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Geist',
                  fontSize: 13,
                  color: resolveThemeColor(
                    context,
                    dark: MyntColors.textSecondaryDark,
                    light: MyntColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 40),
                      side: BorderSide(
                        color: resolveThemeColor(
                          context,
                          dark: MyntColors.outlinedBorderDark,
                          light: MyntColors.outlinedBorder,
                        ),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    child: Text(
                      "Cancel",
                      style: TextStyle(
                        color: resolveThemeColor(
                          context,
                          dark: MyntColors.textPrimaryDark,
                          light: MyntColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await orderProv.removeBsktScrip(index, orderProv.selectedBsktName);
                      await orderProv.fetchBasketMargin();
                      Navigator.pop(dialogContext);
                      showResponsiveSuccess(context, "Removed from basket");
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(0, 40),
                      backgroundColor: resolveThemeColor(
                        context,
                        dark: MyntColors.lossDark,
                        light: MyntColors.loss,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    child: const Text(
                      "Remove",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _showCreateBasket(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          width: 400,
          constraints: const BoxConstraints(maxHeight: 280),
          decoration: BoxDecoration(
            color: resolveThemeColor(dialogContext,
                dark: MyntColors.backgroundColorDark,
                light: MyntColors.backgroundColor),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const CreateBasket(),
        ),
      ),
    ).then((_) async {
      await ref.read(orderProvider).getBasketName();
      _ensureBasketWebSocketSubscription();
    });
  }

  void _showBasketSelector(BuildContext context) {
    final orderProv = ref.read(orderProvider);
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          width: 400,
          constraints: const BoxConstraints(maxHeight: 450),
          decoration: BoxDecoration(
            color: resolveThemeColor(dialogContext,
                dark: MyntColors.backgroundColorDark,
                light: MyntColors.backgroundColor),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Select Basket",
                      style: TextStyle(
                        fontFamily: 'Geist',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: resolveThemeColor(
                          dialogContext,
                          dark: MyntColors.textPrimaryDark,
                          light: MyntColors.textPrimary,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: orderProv.bsktList.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (itemContext, index) {
                    final basket = orderProv.bsktList[index];
                    final basketName = basket['bsketName'].toString();
                    final isSelected = basketName == orderProv.selectedBsktName;
                    return ListTile(
                      leading: Icon(
                        Icons.folder,
                        color: isSelected
                            ? resolveThemeColor(itemContext,
                                dark: MyntColors.primaryDark,
                                light: MyntColors.primary)
                            : resolveThemeColor(itemContext,
                                dark: MyntColors.iconDark, light: MyntColors.icon),
                      ),
                      title: Text(
                        basketName,
                        style: TextStyle(
                          fontFamily: 'Geist',
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          color: isSelected
                              ? resolveThemeColor(itemContext,
                                  dark: MyntColors.primaryDark,
                                  light: MyntColors.primary)
                              : resolveThemeColor(itemContext,
                                  dark: MyntColors.textPrimaryDark,
                                  light: MyntColors.textPrimary),
                        ),
                      ),
                      subtitle: Text(
                        "${basket['curLength']}/${basket['max']} items",
                        style: TextStyle(
                          fontFamily: 'Geist',
                          fontSize: 12,
                          color: resolveThemeColor(
                            itemContext,
                            dark: MyntColors.textSecondaryDark,
                            light: MyntColors.textSecondary,
                          ),
                        ),
                      ),
                      trailing: isSelected
                          ? Icon(
                              Icons.check_circle,
                              color: resolveThemeColor(itemContext,
                                  dark: MyntColors.primaryDark,
                                  light: MyntColors.primary),
                            )
                          : null,
                      onTap: () async {
                        Navigator.pop(dialogContext);
                        await orderProv.chngBsktName(basketName, context, true);
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
