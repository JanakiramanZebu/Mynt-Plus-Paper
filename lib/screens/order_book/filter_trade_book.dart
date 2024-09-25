import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../res/res.dart';
import '../../locator/preference.dart';
import '../../provider/order_provider.dart';
import '../../provider/thems.dart';
import '../../sharedWidget/custom_drag_handler.dart';
import '../../sharedWidget/list_divider.dart';

class OrderbookTradeBookFilterBottomSheet extends StatefulWidget {
  const OrderbookTradeBookFilterBottomSheet({super.key});

  @override
  State<OrderbookTradeBookFilterBottomSheet> createState() =>
      _OrderbookTradeBookFilterBottomSheetState();
}

class _OrderbookTradeBookFilterBottomSheetState
    extends State<OrderbookTradeBookFilterBottomSheet> {
  Preferences pref = Preferences();
  late bool scripisAscending;
  late bool pricepisAscending;
  late bool buyOrsellisAscending;
  late bool timeisAscending;

  @override
  void initState() {
    setState(() {
      scripisAscending = pref.isTBScripname ?? true;
      pricepisAscending = pref.isTBPrice ?? true;
      buyOrsellisAscending = pref.isTBBuyorSell ?? true;
      timeisAscending = pref.isTBTime ?? true;
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.read(themeProvider);
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
          boxShadow: const [
            BoxShadow(
                color: Color(0xff999999),
                blurRadius: 4.0,
                offset: Offset(2.0, 0.0))
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const CustomDragHandler(),
          Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Sort by",
                        style: textStyles.appBarTitleTxt.copyWith(
                            color: !theme.isDarkMode
                                ? colors.colorBlack
                                : colors.colorWhite))
                  ])),
          Divider(
              color: theme.isDarkMode
                  ? colors.darkColorDivider
                  : colors.colorDivider),
          InkWell(
            onTap: () {
              setState(() {
                if (scripisAscending == true) {
                  context.read(orderProvider).filterTradeBook("ASC");
                } else if (scripisAscending == false) {
                  context.read(orderProvider).filterTradeBook("DSC");
                }

                scripisAscending = !scripisAscending;
                pref.setTbScrip(scripisAscending);
                Navigator.pop(context);
              });
            },
            child: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        pref.isTBScripname == true
                            ? "Scrip - A to Z"
                            : "Scrip - Z to A",
                        style: textStyles.prdText,
                      ),
                      Icon(
                        pref.isTBScripname == true
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                        size: 20,
                        color: colors.colorGrey,
                      )
                    ],
                  ),
                ),
                const ListDivider(),
              ],
            ),
          ),
          InkWell(
            onTap: () {
              setState(() {
                if (pricepisAscending == true) {
                  context.read(orderProvider).filterTradeBook("LTPDSC");
                } else if (pricepisAscending == false) {
                  context.read(orderProvider).filterTradeBook("LTPASC");
                }

                pricepisAscending = !pricepisAscending;
                pref.setTbPrice(pricepisAscending);
                Navigator.pop(context);
              });
            },
            child: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        pref.isTBPrice == true
                            ? "Price - High to Low"
                            : "Price - Low to High",
                        style: textStyles.prdText,
                      ),
                      Icon(
                        pref.isTBPrice == true
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                        size: 20,
                        color: colors.colorGrey,
                      )
                    ],
                  ),
                ),
                const ListDivider(),
              ],
            ),
          ),
          InkWell(
            onTap: () {
              setState(() {
                if (buyOrsellisAscending == true) {
                  context.read(orderProvider).filterTradeBook("BUY");
                } else if (buyOrsellisAscending == false) {
                  context.read(orderProvider).filterTradeBook("SELL");
                }

                buyOrsellisAscending = !buyOrsellisAscending;
                pref.setTbBuyOrSell(buyOrsellisAscending);
                Navigator.pop(context);
              });
            },
            child: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        pref.isTBBuyorSell == true ? "Buy" : "Sell",
                        style: textStyles.prdText,
                      ),
                      Icon(
                        pref.isTBBuyorSell == true
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                        size: 20,
                        color: colors.colorGrey,
                      )
                    ],
                  ),
                ),
                const ListDivider(),
              ],
            ),
          ),
          InkWell(
            onTap: () {
              setState(() {
                if (timeisAscending == true) {
                  context.read(orderProvider).filterTradeBook("TIMEHIGH");
                } else if (timeisAscending == false) {
                  context.read(orderProvider).filterTradeBook("TIMELOW");
                }

                timeisAscending = !timeisAscending;
                pref.setTbTime(timeisAscending);
                Navigator.pop(context);
              });
            },
            child: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Time",
                        style: textStyles.prdText,
                      ),
                      Icon(
                        pref.isTBTime == true
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                        size: 20,
                        color: colors.colorGrey,
                      )
                    ],
                  ),
                ),
                const ListDivider(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
