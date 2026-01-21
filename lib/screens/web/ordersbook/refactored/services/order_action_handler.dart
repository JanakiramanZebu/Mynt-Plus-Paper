import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;
import 'package:mynt_plus/models/order_book_model/order_book_model.dart';
import 'package:mynt_plus/models/order_book_model/gtt_order_book.dart';
import 'package:mynt_plus/provider/order_provider.dart';
import 'package:mynt_plus/provider/market_watch_provider.dart';
import 'package:mynt_plus/provider/thems.dart';
import 'package:mynt_plus/utils/responsive_navigation.dart';
import 'package:mynt_plus/utils/responsive_snackbar.dart';
import 'package:mynt_plus/screens/web/ordersbook/modify_gtt_web.dart';
import 'package:mynt_plus/screens/web/ordersbook/order_book_detail_screen_web.dart';
import 'package:mynt_plus/screens/web/ordersbook/trade_book_detail_screen_web.dart';
import 'package:mynt_plus/screens/web/ordersbook/gtt_order_book_detail_screen_web.dart';
import 'package:mynt_plus/screens/web/order/modify_place_order_web_screen.dart';
import 'package:mynt_plus/res/res.dart';
import 'package:mynt_plus/res/web_colors.dart';
import 'package:mynt_plus/res/global_font_web.dart';
import 'package:mynt_plus/res/mynt_web_color_styles.dart' as NewColors;
import 'package:mynt_plus/res/mynt_web_text_styles.dart';

/// Service class to handle order actions (Cancel, Modify, Repeat)
/// Separated from UI to improve maintainability
class OrderActionHandler {
  final WidgetRef ref;
  final BuildContext context;

  OrderActionHandler({
    required this.ref,
    required this.context,
  });

  /// Open order detail sheet
  void openOrderDetail(OrderBookModel order) {
    final parentCtx = context; // Capture the parent context
    shadcn.openSheet(
      context: context,
      builder: (sheetContext) {
        final screenWidth = MediaQuery.of(sheetContext).size.width;
        final sheetWidth = screenWidth < 1300 ? screenWidth * 0.3 : 480.0;
        return Container(
          width: sheetWidth,
          decoration: BoxDecoration(
            color: resolveThemeColor(
              context,
              dark: NewColors.MyntColors.backgroundColorDark,
              light: NewColors.MyntColors.backgroundColor,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 5,
                offset: const Offset(-2, 0),
              ),
            ],
          ),
          child: OrderBookDetailScreenWeb(
            orderBookData: order,
            parentContext: parentCtx, // Pass the parent context
          ),
        );
      },
      position: shadcn.OverlayPosition.end,
      barrierColor: Colors.transparent,
    );
  }

  /// Open trade detail dialog
  void openTradeDetail(dynamic trade) {
    shadcn.openSheet(
      context: context,
      builder: (sheetContext) {
        final screenWidth = MediaQuery.of(sheetContext).size.width;
        final sheetWidth = screenWidth < 500 ? screenWidth * 0.3 : 480.0;
        return Container(
          width: sheetWidth,
          decoration: BoxDecoration(
            color: resolveThemeColor(
              context,
              dark: NewColors.MyntColors.backgroundColorDark,
              light: NewColors.MyntColors.backgroundColor,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 5,
                offset: const Offset(-2, 0),
              ),
            ],
          ),
          child: TradeBookDetailScreenWeb(tradeData: trade),
        );
      },
      position: shadcn.OverlayPosition.end,
      barrierColor: Colors.transparent,
    );
  }

  /// Open GTT order detail dialog
  void openGttOrderDetail(GttOrderBookModel gttOrder) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return GttOrderBookDetailScreenWeb(gttOrder: gttOrder);
      },
    );
  }

  /// Cancel order with confirmation
  Future<bool> cancelOrder(
    OrderBookModel orderData, {
    required Function(bool) onProcessingStateChanged,
  }) async {
    try {
      onProcessingStateChanged(true);

      // Show confirmation dialog
      final shouldCancel = await _showCancelOrderDialog(orderData);

      if (shouldCancel != true) {
        onProcessingStateChanged(false);
        return false;
      }

      // Proceed with cancel
      final cancelResult = await ref.read(orderProvider).fetchOrderCancel(
            "${orderData.norenordno}",
            context,
            false,
          );

      // Refresh order book after successful cancel
      if (cancelResult != null && cancelResult.stat == "Ok") {
        await ref.read(orderProvider).fetchOrderBook(context, true);
        if (context.mounted) {
          ResponsiveSnackBar.showSuccess(context, 'Order Cancelled');
        }
        return true;
      }
      return false;
    } catch (e) {
      if (context.mounted) {
        ResponsiveSnackBar.showError(context, 'Failed to cancel order');
      }
      return false;
    } finally {
      onProcessingStateChanged(false);
    }
  }

  /// Modify order
  Future<void> modifyOrder(
    OrderBookModel orderData, {
    required Function(bool) onProcessingStateChanged,
    required Offset modifyDialogPosition,
    required Function(Offset) onPositionChanged,
  }) async {
    try {
      onProcessingStateChanged(true);

      print('🔵 [HOVER MODIFY] Starting modify order from hover button');
      print('🔵 [HOVER MODIFY] Order Data:');
      print('  - token: ${orderData.token}');
      print('  - exch: ${orderData.exch}');
      print('  - tsym: ${orderData.tsym}');
      print('  - norenordno: ${orderData.norenordno}');
      print('  - qty: ${orderData.qty}');
      print('  - prc: ${orderData.prc}');
      print('  - trgprc: ${orderData.trgprc}');
      print('  - trantype: ${orderData.trantype}');
      print('  - prd: ${orderData.prd}');
      print('  - sPrdtAli: ${orderData.sPrdtAli}');
      print('  - status: ${orderData.status}');
      print('🔵 [HOVER MODIFY] Context mounted: ${context.mounted}');

      await ref.read(marketWatchProvider).fetchScripInfo(
            "${orderData.token}",
            '${orderData.exch}',
            context,
            true,
          );

      if (!context.mounted) {
        print('🔵 [HOVER MODIFY] Context not mounted after fetchScripInfo');
        return;
      }

      final scripInfo = ref.read(marketWatchProvider).scripInfoModel;
      if (scripInfo == null) {
        print('🔵 [HOVER MODIFY] ERROR: scripInfo is null');
        ResponsiveSnackBar.showError(
            context, 'Unable to fetch scrip information');
        return;
      }

      print('🔵 [HOVER MODIFY] scripInfo fetched successfully');

      final orderArgs = _createOrderArgs(orderData);
      print('🔵 [HOVER MODIFY] OrderArgs created:');
      print('  - exchange: ${orderArgs.exchange}');
      print('  - tSym: ${orderArgs.tSym}');
      print('  - token: ${orderArgs.token}');
      print('  - ltp: ${orderArgs.ltp}');
      print('  - prd: ${orderArgs.prd}');
      print('  - lotSize: ${orderArgs.lotSize}');
      print('  - transType: ${orderArgs.transType}');
      print(
          '🔵 [HOVER MODIFY] Calling showDraggable with initialPosition: $modifyDialogPosition');

      // Show draggable modify order dialog
      ModifyPlaceOrderScreenWeb.showDraggable(
        context: context,
        modifyOrderArgs: orderData,
        scripInfo: scripInfo,
        orderArg: orderArgs,
        initialPosition: modifyDialogPosition,
      );

      print('🔵 [HOVER MODIFY] showDraggable called successfully');

      // Refresh order book after a short delay
      if (context.mounted) {
        Future.delayed(const Duration(milliseconds: 500), () async {
          if (context.mounted) {
            await ref.read(orderProvider).fetchOrderBook(context, true);
          }
        });
      }
    } catch (e) {
      if (context.mounted) {
        ResponsiveSnackBar.showError(
            context, 'Failed to open modify order: ${e.toString()}');
      }
    } finally {
      onProcessingStateChanged(false);
    }
  }

  /// Repeat order
  Future<void> repeatOrder(OrderBookModel orderData) async {
    try {
      await ref.read(marketWatchProvider).fetchScripInfo(
            "${orderData.token}",
            "${orderData.exch}",
            context,
            true,
          );

      if (!context.mounted) return;

      final scripInfo = ref.read(marketWatchProvider).scripInfoModel;
      if (scripInfo == null) {
        ResponsiveSnackBar.showError(
            context, 'Unable to fetch scrip information');
        return;
      }

      // Create OrderScreenArgs for repeat order
      final orderArgs = _createOrderArgs(orderData);

      // Use ResponsiveNavigation instead of draggable dialog
      await ResponsiveNavigation.toPlaceOrderScreen(
        context: context,
        arguments: {
          "orderArg": orderArgs,
          "scripInfo": scripInfo,
          "isBskt": "",
        },
      );
    } catch (e) {
      if (context.mounted) {
        ResponsiveSnackBar.showError(
            context, 'Failed to open place order: ${e.toString()}');
      }
    }
  }

  /// Cancel GTT order
  Future<bool> cancelGttOrder(
    GttOrderBookModel gttOrderData, {
    required Function(bool) onProcessingStateChanged,
  }) async {
    try {
      onProcessingStateChanged(true);

      // Show confirmation dialog
      final shouldCancel = await _showCancelGttOrderDialog(gttOrderData);

      if (shouldCancel != true) {
        onProcessingStateChanged(false);
        return false;
      }

      // Cancel the GTT order
      await ref.read(orderProvider).cancelGttOrder(
            "${gttOrderData.alId}",
            context,
          );

      // Refresh GTT order book after successful cancel
      await ref.read(orderProvider).fetchGTTOrderBook(context, "");
      return true;
    } catch (e) {
      if (context.mounted) {
        ResponsiveSnackBar.showError(context, 'Failed to cancel GTT order');
      }
      return false;
    } finally {
      onProcessingStateChanged(false);
    }
  }

  /// Modify GTT order
  Future<void> modifyGttOrder(
    GttOrderBookModel gttOrderData, {
    required Function(bool) onProcessingStateChanged,
  }) async {
    try {
      onProcessingStateChanged(true);

      await ref.read(marketWatchProvider).fetchScripInfo(
            "${gttOrderData.token}",
            '${gttOrderData.exch}',
            context,
            true,
          );

      if (!context.mounted) return;

      final scripInfo = ref.read(marketWatchProvider).scripInfoModel;
      if (scripInfo == null) {
        ResponsiveSnackBar.showError(
            context, 'Unable to fetch scrip information');
        return;
      }

      // Show modify GTT order screen as draggable dialog
      ModifyGttWeb.showDraggable(
        context: context,
        gttOrderBook: gttOrderData,
        scripInfo: scripInfo,
      );
    } catch (e) {
      if (context.mounted) {
        ResponsiveSnackBar.showError(
            context, 'Failed to open modify GTT order: ${e.toString()}');
      }
    } finally {
      onProcessingStateChanged(false);
    }
  }

  // Private helper methods

  Future<bool?> _showCancelOrderDialog(OrderBookModel orderData) async {
    final theme = ref.read(themeProvider);
    final symbol = orderData.tsym?.replaceAll("-EQ", "") ?? 'N/A';
    final exchange = orderData.exch ?? '';
    final displayText = '$symbol $exchange'.trim();

    return showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor:
              theme.isDarkMode ? WebDarkColors.surface : WebColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          child: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                        'Cancel Order',
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
                          customBorder: const CircleBorder(),
                          splashColor: theme.isDarkMode
                              ? Colors.white.withOpacity(.15)
                              : Colors.black.withOpacity(.15),
                          highlightColor: theme.isDarkMode
                              ? Colors.white.withOpacity(.08)
                              : Colors.black.withOpacity(.08),
                          onTap: () => Navigator.of(dialogContext).pop(false),
                          child: Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: Icon(
                              Icons.close,
                              size: 20,
                              color: theme.isDarkMode
                                  ? WebDarkColors.iconSecondary
                                  : WebColors.iconSecondary,
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
                              'Are you sure you want to cancel this order?',
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
                                  ? WebDarkColors.error
                                  : WebColors.error,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(5),
                                splashColor: Colors.white.withOpacity(0.2),
                                highlightColor: Colors.white.withOpacity(0.1),
                                onTap: () =>
                                    Navigator.of(dialogContext).pop(true),
                                child: Center(
                                  child: Text(
                                    'Cancel Order',
                                    style: WebTextStyles.buttonMd(
                                      isDarkTheme: theme.isDarkMode,
                                      color: Colors.white,
                                    ),
                                  ),
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

  Future<bool?> _showCancelGttOrderDialog(
      GttOrderBookModel gttOrderData) async {
    final theme = ref.read(themeProvider);
    final symbol = gttOrderData.tsym?.replaceAll("-EQ", "") ?? 'N/A';
    final exchange = gttOrderData.exch ?? '';
    final displayText = '$symbol $exchange'.trim();

    return showDialog<bool>(
      context: context,
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                          customBorder: const CircleBorder(),
                          splashColor: theme.isDarkMode
                              ? Colors.white.withOpacity(.15)
                              : Colors.black.withOpacity(.15),
                          highlightColor: theme.isDarkMode
                              ? Colors.white.withOpacity(.08)
                              : Colors.black.withOpacity(.08),
                          onTap: () => Navigator.of(dialogContext).pop(false),
                          child: Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: Icon(
                              Icons.close,
                              size: 20,
                              color: theme.isDarkMode
                                  ? WebDarkColors.iconSecondary
                                  : WebColors.iconSecondary,
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
                                  ? WebDarkColors.tertiary
                                  : WebColors.tertiary,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(5),
                                splashColor: Colors.white.withOpacity(0.2),
                                highlightColor: Colors.white.withOpacity(0.1),
                                onTap: () =>
                                    Navigator.of(dialogContext).pop(true),
                                child: Center(
                                  child: Text(
                                    'Cancel Order',
                                    style: WebTextStyles.buttonMd(
                                      isDarkTheme: theme.isDarkMode,
                                      color: Colors.white,
                                    ),
                                  ),
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

  dynamic _createOrderArgs(OrderBookModel orderData) {
    // Get LTP, fallback to close price if numeric, otherwise use 0.00
    String ltpValue = "0.00";
    if (orderData.ltp != null && orderData.ltp.toString() != "null") {
      ltpValue = orderData.ltp.toString();
    } else if (orderData.c != null && orderData.c.toString() != "null") {
      final closePrice = double.tryParse(orderData.c.toString());
      if (closePrice != null) {
        ltpValue = closePrice.toString();
      }
    }

    return OrderScreenArgs(
      exchange: orderData.exch ?? '',
      tSym: orderData.tsym ?? '',
      isExit: false,
      token: orderData.token ?? '',
      transType: orderData.trantype == 'B' ? true : false,
      prd: orderData.prd ?? orderData.sPrdtAli ?? 'CNC',
      lotSize: orderData.ls ?? '1',
      ltp: ltpValue,
      perChange: orderData.change ?? "0.00",
      orderTpye: '',
      holdQty: '',
      isModify: false,
      raw: orderData.toJson(),
    );
  }
}
