import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../res/res.dart';
import '../../locator/preference.dart';
import '../../provider/order_provider.dart';
import '../../provider/thems.dart';
import '../../sharedWidget/custom_drag_handler.dart';
import '../../sharedWidget/list_divider.dart';

class OrderbookFilterBottomSheet extends ConsumerStatefulWidget {
  const OrderbookFilterBottomSheet({super.key});

  @override
  ConsumerState<OrderbookFilterBottomSheet> createState() =>
      _OrderbookFilterBottomSheetState();
}

class _OrderbookFilterBottomSheetState
    extends ConsumerState<OrderbookFilterBottomSheet> {
  Preferences pref = Preferences();
  late bool scripisAscending;
  late bool pricepisAscending;
  late bool qtyisAscending;
  late bool productisAscending;
  late bool timeisAscending;

  @override
  void initState() {
    setState(() {
      scripisAscending = pref.isObScripname ?? true;
      pricepisAscending = pref.isObPrice ?? true;
      qtyisAscending = pref.isObqty ?? true;
      productisAscending = pref.isObProduct ?? true;
      timeisAscending = pref.isObtime ?? true;
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.read(themeProvider);
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
                  ref.read(orderProvider).filterOrders(sorting: "ASC");
                } else if (scripisAscending == false) {
                  ref.read(orderProvider).filterOrders(sorting: "DSC");
                }

                scripisAscending = !scripisAscending;
                pref.setOBScrip(scripisAscending);
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
                        pref.isObScripname == true
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
                  ref.read(orderProvider).filterOrders(sorting: "PRODUCTASC");
                } else if (productisAscending == false) {
                  ref.read(orderProvider).filterOrders(sorting: "PRODUCTDSC");
                }

                productisAscending = !productisAscending;
                pref.setOBproduct(productisAscending);
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
                        pref.isObProduct == true
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
                  ref.read(orderProvider).filterOrders(sorting: "QTYDSC");
                } else if (qtyisAscending == false) {
                  ref.read(orderProvider).filterOrders(sorting: "QTYASC");
                }

                qtyisAscending = !qtyisAscending;
                pref.setOBqty(qtyisAscending);
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
                        pref.isObqty == true
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
                  ref.read(orderProvider).filterOrders(sorting: "LTPDSC");
                } else if (pricepisAscending == false) {
                  ref.read(orderProvider).filterOrders(sorting: "LTPASC");
                }

                pricepisAscending = !pricepisAscending;
                pref.setOBPrice(pricepisAscending);
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
                        pref.isObPrice == true
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
                  ref.read(orderProvider).filterOrders(sorting: "TIMEDSC");
                } else if (timeisAscending == false) {
                  ref.read(orderProvider).filterOrders(sorting: "TIMEASC");
                }

                timeisAscending = !timeisAscending;
                pref.setOBtime(timeisAscending);
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
                        pref.isObtime == true
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
