import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../res/res.dart';
import '../../locator/preference.dart';
import '../../provider/order_provider.dart';
import '../../provider/thems.dart';
import '../../sharedWidget/custom_drag_handler.dart';
import '../../sharedWidget/list_divider.dart';

class OrderbooGTTkFilterBottomSheet extends StatefulWidget {
  const OrderbooGTTkFilterBottomSheet({super.key});

  @override
  State<OrderbooGTTkFilterBottomSheet> createState() =>
      _OrderbooGTTkFilterBottomSheetState();
}

class _OrderbooGTTkFilterBottomSheetState
    extends State<OrderbooGTTkFilterBottomSheet> {
  Preferences pref = Preferences();
  late bool scripisAscending;
  late bool pricepisAscending;
  late bool qtyisAscending;
  late bool productisAscending;
  late bool timeisAscending;

  @override
  void initState() {
    setState(() {
      scripisAscending = pref.isGttScripname ?? true;
      pricepisAscending = pref.isGttPrice ?? true;
      qtyisAscending = pref.isGttqty ?? true;
      productisAscending = pref.isGttProduct ?? true;
      timeisAscending = pref.isGtttime ?? true;
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
                  context.read(orderProvider).filterGttOrders("ASC");
                } else if (scripisAscending == false) {
                  context.read(orderProvider).filterGttOrders("DSC");
                }

                scripisAscending = !scripisAscending;
                pref.setGTTScrip(scripisAscending);
                Navigator.pop(context);
              });
            },
            child: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                  child: Row(
                    children: [
                      Icon(
                        pref.isGttScripname == true
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                        size: 20,
                        color: colors.colorGrey,
                      ),
                      const SizedBox(
                        width: 15,
                      ),
                      Text(
                        "Scrip Name",
                        style: textStyles.prdText,
                      ),
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
                if (productisAscending == true) {
                  context.read(orderProvider).filterGttOrders("PRODUCTASC");
                } else if (productisAscending == false) {
                  context.read(orderProvider).filterGttOrders("PRODUCTDSC");
                }

                productisAscending = !productisAscending;
                pref.setGTTproduct(productisAscending);
                Navigator.pop(context);
              });
            },
            child: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                  child: Row(
                    children: [
                      Icon(
                        pref.isGttProduct == true
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                        size: 20,
                        color: colors.colorGrey,
                      ),
                      const SizedBox(
                        width: 15,
                      ),
                      Text(
                        "Product",
                        style: textStyles.prdText,
                      ),
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
                if (qtyisAscending == true) {
                  context.read(orderProvider).filterGttOrders("QTYDSC");
                } else if (qtyisAscending == false) {
                  context.read(orderProvider).filterGttOrders("QTYASC");
                }

                qtyisAscending = !qtyisAscending;
                pref.setGTTqty(qtyisAscending);
                Navigator.pop(context);
              });
            },
            child: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                  child: Row(
                    children: [
                      Icon(
                        pref.isGttqty == true
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                        size: 20,
                        color: colors.colorGrey,
                      ),
                      const SizedBox(
                        width: 15,
                      ),
                      Text(
                        "Qty",
                        style: textStyles.prdText,
                      ),
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
                  context.read(orderProvider).filterGttOrders("LTPDSC");
                } else if (pricepisAscending == false) {
                  context.read(orderProvider).filterGttOrders("LTPASC");
                }

                pricepisAscending = !pricepisAscending;
                pref.setGTTPrice(pricepisAscending);
                Navigator.pop(context);
              });
            },
            child: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                  child: Row(
                    children: [
                      Icon(
                        pref.isGttPrice == true
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                        size: 20,
                        color: colors.colorGrey,
                      ),
                      const SizedBox(
                        width: 15,
                      ),
                      Text(
                        "LTP",
                        style: textStyles.prdText,
                      ),
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
                  context.read(orderProvider).filterGttOrders("TIMEDSC");
                } else if (timeisAscending == false) {
                  context.read(orderProvider).filterGttOrders("TIMEASC");
                }

                timeisAscending = !timeisAscending;
                pref.setGTTtime(timeisAscending);
                Navigator.pop(context);
              });
            },
            child: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                  child: Row(
                    children: [
                      Icon(
                        pref.isGtttime == true
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                        size: 20,
                        color: colors.colorGrey,
                      ),
                      const SizedBox(
                        width: 15,
                      ),
                      Text(
                        "Time",
                        style: textStyles.prdText,
                      ),
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
