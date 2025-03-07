import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../provider/order_provider.dart';
import '../../provider/thems.dart';
import '../../res/res.dart';
import 'basket/basket_list.dart';
import 'gtt_order_book.dart';
import 'order_book.dart';
import 'pending_alert_card.dart';
import 'sip_order_book_screen.dart';
import 'trade_book.dart';

class OrderBookScreen extends StatefulWidget {
  const OrderBookScreen({super.key});

  @override
  State<OrderBookScreen> createState() => _OrderBookScreenState();
}

class _OrderBookScreenState extends State<OrderBookScreen>
    with TickerProviderStateMixin {
  @override
  void initState() {
    setState(() {
      context.read(orderProvider).tabCtrl = TabController(
          length: context.read(orderProvider).orderTabName.length,
          vsync: this,
          initialIndex: context.read(orderProvider).selectedTab);

      context.read(orderProvider).tabCtrl.addListener(() {
        context
            .read(orderProvider)
            .changeTabIndex(context.read(orderProvider).tabCtrl.index, context);
      });
    });

    FirebaseAnalytics.instance.logScreenView(
 screenName: 'Place order screen',
      screenClass: 'Order_screen',
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ScopedReader watch, _) {
      final orderBook = watch(orderProvider);
      final theme = watch(themeProvider);
      final sipBook = watch(orderProvider);

      return orderBook.loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                  Container(
                      padding: EdgeInsets.zero,
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                  color: theme.isDarkMode
                                      ? colors.darkColorDivider
                                      : colors.colorDivider,
                                  width: 0))),
                      height: 46,
                      child: TabBar(
                          tabAlignment: TabAlignment.start,
                          indicatorSize: TabBarIndicatorSize.tab,
                          isScrollable: true,
                          indicatorColor: theme.isDarkMode
                              ? colors.colorLightBlue
                              : colors.colorBlue,
                          unselectedLabelColor: const Color(0XFF777777),
                          unselectedLabelStyle: GoogleFonts.inter(
                              textStyle: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: -0.28)),
                          labelColor: theme.isDarkMode
                              ? colors.colorLightBlue
                              : colors.colorBlue,
                          labelStyle: GoogleFonts.inter(
                              textStyle: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w600)),
                          controller: orderBook.tabCtrl,
                          tabs: orderBook.orderTabName)),
                  Expanded(
                      child:
                          TabBarView(controller: orderBook.tabCtrl, children: [
                    OrderBook(orderBook: orderBook.allOrder!),
                    OrderBook(orderBook: orderBook.openOrder!),
                    OrderBook(orderBook: orderBook.executedOrder!),
                    GttOrderBook(
                        gttOrderBook: orderBook.gttOrderBookModel ?? []),
                    const BasketList(),
                    TradeBook(tradeBook: orderBook.tradeBook ?? []),
                    const PendingAlert(),
                    SipOrderBook(
                      sipbook: sipBook.siporderBookModel?.sipDetails,
                    )
                  ]))
                ]);
    });
  }
}
