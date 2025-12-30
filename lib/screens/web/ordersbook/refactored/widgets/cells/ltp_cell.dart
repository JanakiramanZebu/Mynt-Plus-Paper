import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/models/order_book_model/order_book_model.dart';
import 'package:mynt_plus/models/order_book_model/gtt_order_book.dart';
import 'package:mynt_plus/provider/websocket_provider.dart';
import 'package:mynt_plus/provider/thems.dart';
import 'package:mynt_plus/res/web_colors.dart';
import 'package:mynt_plus/res/global_font_web.dart';

/// Isolated widget for Order Book LTP - only this rebuilds when LTP changes
class OrderBookLTPCell extends ConsumerStatefulWidget {
  final String token;
  final String initialLtp;
  final OrderBookModel order;
  final ThemesProvider theme;

  const OrderBookLTPCell({
    super.key,
    required this.token,
    required this.initialLtp,
    required this.order,
    required this.theme,
  });

  @override
  ConsumerState<OrderBookLTPCell> createState() => _OrderBookLTPCellState();
}

class _OrderBookLTPCellState extends ConsumerState<OrderBookLTPCell> {
  late String ltp;
  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    ltp = widget.initialLtp;

    _subscription = ref.read(websocketProvider).socketDataStream.listen((data) {
      if (!mounted || !data.containsKey(widget.token)) return;

      final newLtp = data[widget.token]['lp']?.toString();
      if (newLtp != null && newLtp != ltp && newLtp != '0.00' && newLtp != 'null') {
        setState(() => ltp = newLtp);
        widget.order.ltp = newLtp;
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      ltp,
      textAlign: TextAlign.right,
      style: WebTextStyles.custom(
        fontSize: 13,
        isDarkTheme: widget.theme.isDarkMode,
        color: widget.theme.isDarkMode
            ? WebDarkColors.textPrimary
            : WebColors.textPrimary,
        fontWeight: WebFonts.medium,
      ),
    );
  }
}

/// Isolated widget for GTT LTP - only this rebuilds when LTP changes
class GttLTPCell extends ConsumerStatefulWidget {
  final String token;
  final String initialLtp;
  final GttOrderBookModel gttOrder;
  final ThemesProvider theme;

  const GttLTPCell({
    super.key,
    required this.token,
    required this.initialLtp,
    required this.gttOrder,
    required this.theme,
  });

  @override
  ConsumerState<GttLTPCell> createState() => _GttLTPCellState();
}

class _GttLTPCellState extends ConsumerState<GttLTPCell> {
  late String ltp;
  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    ltp = widget.initialLtp;

    _subscription = ref.read(websocketProvider).socketDataStream.listen((data) {
      if (!mounted || !data.containsKey(widget.token)) return;

      final newLtp = data[widget.token]['lp']?.toString();
      if (newLtp != null && newLtp != ltp && newLtp != '0.00' && newLtp != 'null') {
        setState(() => ltp = newLtp);
        widget.gttOrder.ltp = newLtp;
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      ltp,
      textAlign: TextAlign.right,
      style: WebTextStyles.custom(
        fontSize: 13,
        isDarkTheme: widget.theme.isDarkMode,
        color: widget.theme.isDarkMode
            ? WebDarkColors.textPrimary
            : WebColors.textPrimary,
        fontWeight: WebFonts.medium,
      ),
    );
  }
}

