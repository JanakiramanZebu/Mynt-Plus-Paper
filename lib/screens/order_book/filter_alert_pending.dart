import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../res/res.dart';
import '../../locator/preference.dart';
import '../../provider/market_watch_provider.dart';
import '../../provider/thems.dart';
import '../../sharedWidget/custom_drag_handler.dart';
import '../../sharedWidget/list_divider.dart';

class OrderbookPendingAlertkFilterBottomSheet extends StatefulWidget {
  const OrderbookPendingAlertkFilterBottomSheet({super.key});

  @override
  State<OrderbookPendingAlertkFilterBottomSheet> createState() =>
      _OrderbookPendingAlertkFilterBottomSheetState();
}

class _OrderbookPendingAlertkFilterBottomSheetState
    extends State<OrderbookPendingAlertkFilterBottomSheet> {
  Preferences pref = Preferences();
  late bool scripisAscending;
  late bool pricepisAscending;
  late bool alertvalueisAscending;

  @override
  void initState() {
    setState(() {
      scripisAscending = pref.isPAScripname ?? true;
      pricepisAscending = pref.isPAPrice ?? true;
      alertvalueisAscending = pref.isPAPricealert ?? true;
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
                  context.read(marketWatchProvider).filterPendingAlert("DSC");
                } else if (scripisAscending == false) {
                  context.read(marketWatchProvider).filterPendingAlert("ASC");
                }

                scripisAscending = !scripisAscending;
                pref.setPAScrip(scripisAscending);
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
                        pref.isPAScripname == true
                            ? "Scrip - A to Z"
                            : "Scrip - Z to A",
                        style: textStyles.prdText,
                      ),
                      Icon(
                        pref.isPAScripname == true
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
                  context
                      .read(marketWatchProvider)
                      .filterPendingAlert("LTPASC");
                } else if (pricepisAscending == false) {
                  context
                      .read(marketWatchProvider)
                      .filterPendingAlert("LTPDSC");
                }

                pricepisAscending = !pricepisAscending;
                pref.setPAPrice(pricepisAscending);
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
                        pref.isPAPrice == true
                            ? "Price - High to Low"
                            : "Price - Low to High",
                        style: textStyles.prdText,
                      ),
                      Icon(
                        pref.isPAPrice == true
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
                if (alertvalueisAscending == true) {
                  context
                      .read(marketWatchProvider)
                      .filterPendingAlert("ALERTVALUEASC");
                } else if (alertvalueisAscending == false) {
                  context
                      .read(marketWatchProvider)
                      .filterPendingAlert("ALERTVALUEDSC");
                }

                alertvalueisAscending = !alertvalueisAscending;
                pref.setPAPriceAlert(alertvalueisAscending);
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
                        pref.isPAPricealert == true
                            ? "Alert price High to Low"
                            : "Alert price Low to High",
                        style: textStyles.prdText,
                      ),
                      Icon(
                        pref.isPAPricealert == true
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
