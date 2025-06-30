import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../provider/order_provider.dart';
import '../../provider/thems.dart';
import '../../res/global_state_text.dart';
import '../../res/res.dart';
import 'basket/basket_list.dart';
import 'gtt_order_book.dart';
import 'order_book.dart';
import 'pending_alert_card.dart';
import 'sip_order_book_screen.dart';
import 'trade_book.dart';

class OrderBookScreen extends ConsumerStatefulWidget {
  const OrderBookScreen({super.key});

  @override
  ConsumerState<OrderBookScreen> createState() => _OrderBookScreenState();
}

class _OrderBookScreenState extends ConsumerState<OrderBookScreen>
    with TickerProviderStateMixin {
  @override
  void initState() {
    setState(() {
      ref.read(orderProvider).tabCtrl = TabController(
          length: ref.read(orderProvider).orderTabName.length,
          vsync: this,
          initialIndex: ref.read(orderProvider).selectedTab);

      ref.read(orderProvider).tabCtrl.addListener(() {
        ref
            .read(orderProvider)
            .changeTabIndex(ref.read(orderProvider).tabCtrl.index, context);
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
    return Consumer(builder: (context, WidgetRef ref, _) {
      final orderBook = ref.watch(orderProvider);
      final theme = ref.watch(themeProvider);
      final sipBook = ref.watch(orderProvider);

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
                      height: 50,
                      child: Column(
                        children: [
                          TabBar(
                              tabAlignment: TabAlignment.start,
                              indicatorSize: TabBarIndicatorSize.tab,
                              isScrollable: true,
                              indicatorColor: theme.isDarkMode
                                  ? colors.colorLightBlue
                                  : colors.colorBlue,
                              unselectedLabelColor: const Color(0XFF777777),
                              unselectedLabelStyle: TextWidget.textStyle(
                                  fontSize: 12,
                                  theme: false,
                                  fw: 0,
                                  letterSpacing: -0.28),
                              labelColor: theme.isDarkMode
                                  ? colors.colorLightBlue
                                  : colors.colorBlue,
                              labelStyle: TextWidget.textStyle(
                                  fontSize: 14, theme: false, fw: 1),
                              controller: orderBook.tabCtrl,
                              tabs: orderBook.orderTabName),
                              // Divider line
    Container(
      height: 2,
      color:const Color(0xffF1F3F8), // light grey line
    ),
                        ],
                      )),
                  Expanded(
                      child:
                          TabBarView(controller: orderBook.tabCtrl, children: [
                    // OrderBook(orderBook: orderBook.allOrder!),
                    OrderBook(orderBook: orderBook.openOrder!),
                    OrderBook(orderBook: orderBook.executedOrder!),
                    GttOrderBook(
                        gttOrderBook: orderBook.gttOrderBookModel ?? []),
                    const BasketList(),
                    // TradeBook(tradeBook: orderBook.tradeBook ?? []),
                    
                    SipOrderBook(
                      sipbook: sipBook.siporderBookModel?.sipDetails,
                    ),
                    const PendingAlert(),
                  ]))
                ]);
    });
  }
}
