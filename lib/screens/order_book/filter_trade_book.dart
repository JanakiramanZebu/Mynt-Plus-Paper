import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../res/res.dart';
import '../../locator/preference.dart';
import '../../provider/order_provider.dart';
import '../../provider/thems.dart';
import '../../res/global_state_text.dart';
import '../../sharedWidget/custom_drag_handler.dart';
import '../../sharedWidget/list_divider.dart';

class OrderbookTradeBookFilterBottomSheet extends ConsumerStatefulWidget {
  const OrderbookTradeBookFilterBottomSheet({super.key});

  @override
  ConsumerState<OrderbookTradeBookFilterBottomSheet> createState() =>
      _OrderbookTradeBookFilterBottomSheetState();
}

class _OrderbookTradeBookFilterBottomSheetState
    extends ConsumerState<OrderbookTradeBookFilterBottomSheet> {
  Preferences pref = Preferences();
  late bool scripisAscending;
  late bool buyOrsellisAscending;
  late bool timeisAscending;

  @override
  void initState() {
    setState(() {
      scripisAscending = pref.isTBScripname ?? true;
      buyOrsellisAscending = pref.isTBBuyorSell ?? true;
      timeisAscending = pref.isTBTime ?? true;
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
                  ref.read(orderProvider).filterTradeBook("ASC");
                } else if (scripisAscending == false) {
                  ref.read(orderProvider).filterTradeBook("DSC");
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
                    children: [
                      Icon(
                        pref.isTBScripname == true
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                        size: 20,
                        color: colors.colorGrey,
                      ),
                      const SizedBox(
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
                if (buyOrsellisAscending == true) {
                  ref.read(orderProvider).filterTradeBook("BUY");
                } else if (buyOrsellisAscending == false) {
                  ref.read(orderProvider).filterTradeBook("SELL");
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
                    children: [
                      Icon(
                        pref.isTBBuyorSell == true
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                        size: 20,
                        color: colors.colorGrey,
                      ),
                      const SizedBox(
                        width: 15,
                      ),
                      TextWidget.subText(text: pref.isTBBuyorSell == true ? "Buy" : "Sell",theme: false,color: colors.colorGrey,fw: 0),
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
                  ref.read(orderProvider).filterTradeBook("TIMEHIGH");
                } else if (timeisAscending == false) {
                  ref.read(orderProvider).filterTradeBook("TIMELOW");
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
                    children: [
                      Icon(
                        pref.isTBTime == true
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                        size: 20,
                        color: colors.colorGrey,
                      ),
                      const SizedBox(
                        width: 15,
                      ),
                      TextWidget.subText(text: "Time",theme: false,color: colors.colorGrey,fw: 0),
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
