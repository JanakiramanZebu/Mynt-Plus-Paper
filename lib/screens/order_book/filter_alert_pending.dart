import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../res/res.dart';
import '../../locator/preference.dart';
import '../../provider/market_watch_provider.dart';
import '../../provider/thems.dart';
import '../../res/global_state_text.dart';
import '../../sharedWidget/custom_drag_handler.dart';
import '../../sharedWidget/list_divider.dart';

class OrderbookPendingAlertkFilterBottomSheet extends ConsumerStatefulWidget {
  const OrderbookPendingAlertkFilterBottomSheet({super.key});

  @override
  ConsumerState<OrderbookPendingAlertkFilterBottomSheet> createState() =>
      _OrderbookPendingAlertkFilterBottomSheetState();
}

class _OrderbookPendingAlertkFilterBottomSheetState
    extends ConsumerState<OrderbookPendingAlertkFilterBottomSheet> {
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
                    TextWidget.titleText(text: "Sort by",theme: false,color: !theme.isDarkMode
                                ? colors.colorBlack
                                : colors.colorWhite,fw: 1),
                  ])),
          Divider(
              color: theme.isDarkMode
                  ? colors.darkColorDivider
                  : colors.colorDivider),
          InkWell(
            onTap: () {
              setState(() {
                if (scripisAscending == true) {
                  ref.read(marketWatchProvider).filterPendingAlert("DSC");
                } else if (scripisAscending == false) {
                  ref.read(marketWatchProvider).filterPendingAlert("ASC");
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
                    children: [
                      Icon(
                        pref.isPAScripname == true
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                        size: 20,
                        color: colors.colorGrey,
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      TextWidget.subText(text: "Scrip Name",theme: false,color: colors.colorGrey,fw: 0),
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
                  ref.read(marketWatchProvider).filterPendingAlert("LTPASC");
                } else if (pricepisAscending == false) {
                  ref.read(marketWatchProvider).filterPendingAlert("LTPDSC");
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
                    children: [
                      Icon(
                        pref.isPAPrice == true
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                        size: 20,
                        color: colors.colorGrey,
                      ),
                      const SizedBox(
                        width: 15,
                      ),
                      TextWidget.subText(text: "LTP",theme: false,color: colors.colorGrey,fw: 0),
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
                  ref.read(marketWatchProvider).filterPendingAlert("ALERTVALUEASC");
                } else if (alertvalueisAscending == false) {
                  ref.read(marketWatchProvider).filterPendingAlert("ALERTVALUEDSC");
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
                    children: [
                      Icon(
                        pref.isPAPricealert == true
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                        size: 20,
                        color: colors.colorGrey,
                      ),
                      const SizedBox(
                        width: 15,
                      ),
                      TextWidget.subText(text: "Alert Price",theme: false,color: colors.colorGrey,fw: 0),
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
