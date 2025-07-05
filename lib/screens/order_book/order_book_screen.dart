import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../provider/order_provider.dart';
import '../../provider/thems.dart';
import '../../res/global_state_text.dart';
import '../../res/res.dart';
import '../../sharedWidget/custom_text_form_field.dart';
import 'basket/basket_list.dart';
import 'filter_scrip_bottom_sheet.dart';
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

      return GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: orderBook.loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _buildFilterSearchHeader(orderBook, theme),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    height: 35,
                    // decoration: BoxDecoration(
                    //   border: Border(
                    //     bottom: BorderSide(
                    //       color: theme.isDarkMode ? colors.darkColorDivider : colors.colorDivider,
                    //       width: 1,
                    //     ),
                    //   ),
                    // ),
                    child: TabBar(
                      controller: orderBook.tabCtrl,
                      tabAlignment: TabAlignment.start,
                      isScrollable: true,
                      indicatorSize: TabBarIndicatorSize.label,
                      indicatorColor: colors.colorWhite,          // hide default underline
                      indicator: BoxDecoration(                    // pill-shaped highlight[4]
                        color: const Color(0xffF1F3F8),
                        borderRadius: BorderRadius.circular(6),
                        // border: Border.all(
                        //   color: theme.isDarkMode
                        //       ? colors.darkColorDivider
                        //       : colors.colorDivider,
                        // ),
                      ),
                      // labelColor: theme.isDarkMode
                      //     ? colors.colorLightBlue
                      //     : colors.colorBlue,
                      unselectedLabelColor: const Color(0XFF777777),
                      labelStyle:
                          TextWidget.textStyle(fontSize: 14, theme: false, fw: 1),
                      unselectedLabelStyle: TextWidget.textStyle(
                          fontSize: 14, theme: false, fw: 0, letterSpacing: -0.28),
                      labelPadding: const EdgeInsets.symmetric(horizontal: 4),

                      // build the "Open 4" badge and the rest of the tabs
                      tabs: orderBook.orderTabName.map((tabString) {
                        /// If the value looks like "Open 4", split it once on the space
                        final parts  = tabString.text?.split(' ') ?? [];            // Dart's split()[3]
                        final title  = parts.first;                     // "Open"
                        final badge  = parts.length > 1 ? parts[1] : null;   // "4" or null

                        return Tab(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10, right: 10, top: 0, bottom: 0),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(title),
                                if (badge != null) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: colors.colorWhite,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      badge,
                                      style: TextWidget.textStyle(fontSize: 14, theme: false, fw: 1),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  Expanded(
                      child:
                          TabBarView(controller: orderBook.tabCtrl, children: [
                    // OrderBook(orderBook: orderBook.allOrder!),
                    OrderBook(
                        orderBook: orderBook.orderSearchCtrl.text.isNotEmpty
                            ? orderBook.orderSearchItem ?? []
                            : orderBook.openOrder!),
                    OrderBook(
                        orderBook: orderBook.orderSearchCtrl.text.isNotEmpty
                            ? orderBook.orderSearchItem ?? []
                            : orderBook.executedOrder!),
                    TradeBook(
                        tradeBook: orderBook.orderSearchCtrl.text.isNotEmpty
                            ? orderBook.tradeBooksearch ?? []
                            : orderBook.tradeBook ?? []),

                    GttOrderBook(
                        gttOrderBook: orderBook.orderSearchCtrl.text.isNotEmpty
                            ? orderBook.gttOrderBookSearch ?? []
                            : orderBook.gttOrderBookModel ?? []),
                    const BasketList(),
                    
                    SipOrderBook(
                      sipbook: orderBook.orderSearchCtrl.text.isNotEmpty
                          ? sipBook.siporderBookSearch
                          : sipBook.siporderBookModel?.sipDetails,
                    ),
                    const PendingAlert(),
                      ]))
                ]),
      );
    });
  }

  // Filter and search header
  Widget _buildFilterSearchHeader(OrderProvider order, ThemesProvider theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
        // border: Border(
        //   bottom: BorderSide(
        //     color: theme.isDarkMode ? colors.darkGrey : const Color(0xffF1F3F8),
        //     width: 1,
        //   ),
        // ),
      ),
      child: Container(
  height: 40,
  decoration: BoxDecoration(
    color: const Color(0xffF1F3F8).withOpacity(0.5),
    borderRadius: BorderRadius.circular(5),
  ),
  child: Row(
    children: [
      const SizedBox(width: 12),
      SvgPicture.asset(
        assets.searchIcon,
        width: 14,
        height: 14,
        color: const Color(0xff121212),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: TextFormField(
          controller: order.orderSearchCtrl,
          autofocus: false,
          textCapitalization: TextCapitalization.characters,
          inputFormatters: [UpperCaseTextFormatter()],
          style: TextWidget.textStyle(
            fontSize: 14,
            theme: theme.isDarkMode,
            color: const Color(0xff000000),
            fw: 00,
          ),
          decoration: InputDecoration(
            hintStyle: TextWidget.textStyle(
              fontSize: 14,
              theme: false,
              color: const Color(0xff69758F),
              fw: 00,
            ),
            border: InputBorder.none,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
          onChanged: (value) {
            order.searchOrders(value, context);
          },
        ),
      ),
      if (order.orderSearchCtrl.text.isNotEmpty)
        InkWell(
          onTap: () {
            FocusScope.of(context).unfocus();
            order.clearOrderSearch();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: SvgPicture.asset(
              assets.removeIcon,
              width: 14,
              height: 14,
              color: const Color(0xff121212),
            ),
          ),
        ),
      // const VerticalDivider(
      //   color: Color(0xFFCED3DE),
      //   width: 1,
      //   thickness: 1,
      //   indent: 8,
      //   endIndent: 8,
      // ),
      InkWell(
        onTap: () async {
          FocusScope.of(context).unfocus();
          showModalBottomSheet(
            useSafeArea: true,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            context: context,
            builder: (context) {
              return const OrderbookFilterBottomSheet();
            },
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: SvgPicture.asset(
            assets.filterIcon,
            width: 14,
            height: 14,
            color:const Color(0xff121212),
          ),
        ),
      ),
    ],
  ),
)

    );
  }

}


