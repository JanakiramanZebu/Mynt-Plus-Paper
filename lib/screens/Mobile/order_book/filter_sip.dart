import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../res/res.dart';
import '../../../locator/preference.dart';
import '../../../provider/order_provider.dart';
import '../../../provider/thems.dart';
import '../../../res/global_state_text.dart';
import '../../../sharedWidget/custom_drag_handler.dart';
import '../../../sharedWidget/list_divider.dart';

class OrderbookSipkFilterBottomSheet extends ConsumerStatefulWidget {
  const OrderbookSipkFilterBottomSheet({super.key});

  @override
  ConsumerState<OrderbookSipkFilterBottomSheet> createState() =>
      _OrderbookSipkFilterBottomSheetState();
}

class _OrderbookSipkFilterBottomSheetState
    extends ConsumerState<OrderbookSipkFilterBottomSheet> {
  Preferences pref = Preferences();
  late bool scripisAscending;
  late bool pricepisAscending;
  late bool chnageisAscending;
  late bool dateisAscending;

  @override
  void initState() {
    setState(() {
      scripisAscending = pref.isSipScripname ?? true;
      pricepisAscending = pref.isSipPrice ?? true;
      // chnageisAscending = pref.isSipChange ?? true;
      dateisAscending = pref.isSipDate ?? true;
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
                  ref.read(orderProvider).filterSipOrder("ASC");
                } else if (scripisAscending == false) {
                  ref.read(orderProvider).filterSipOrder("DSC");
                }

                scripisAscending = !scripisAscending;
                pref.setSipScrip(scripisAscending);
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
                        pref.isSipScripname == true
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
                if (pricepisAscending == true) {
                  ref.read(orderProvider).filterSipOrder("LTPDSC");
                } else if (pricepisAscending == false) {
                  ref.read(orderProvider).filterSipOrder("LTPASC");
                }

                pricepisAscending = !pricepisAscending;
                pref.setSipPrice(pricepisAscending);
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
                        pref.isSipPrice == true
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
          // InkWell(
          //   onTap: () {
          //     setState(() {
          //       if (chnageisAscending == true) {
          //         ref.read(orderProvider).filterSipOrder("PRECHANGDSC");
          //       } else if (chnageisAscending == false) {
          //         ref.read(orderProvider).filterSipOrder("PRECHANGASC");
          //       }

          //       chnageisAscending = !chnageisAscending;
          //       pref.setSipChange(chnageisAscending);
          //       Navigator.pop(context);
          //     });
          //   },
          //   child: Column(
          //     children: [
          //       Padding(
          //         padding:
          //             const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          //         child: Row(
          //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //           children: [
          //             Text(
          //               pref.isSipChange == true
          //                   ? "Per.change - High to Low"
          //                   : "Per.change - Low to High",
          //               style: textStyles.prdText,
          //             ),
          //             Icon(
          //               pref.isSipChange == true
          //                   ? Icons.arrow_upward
          //                   : Icons.arrow_downward,
          //               size: 20,
          //               color: colors.colorGrey,
          //             )
          //           ],
          //         ),
          //       ),
          //       const ListDivider(),
          //     ],
          //   ),
          // ),

          InkWell(
            onTap: () {
              setState(() {
                if (dateisAscending == true) {
                  ref.read(orderProvider).filterSipOrder("DATEDSC");
                } else if (dateisAscending == false) {
                  ref.read(orderProvider).filterSipOrder("DATEASC");
                }

                dateisAscending = !dateisAscending;
                pref.setSipDate(dateisAscending);
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
                        pref.isSipDate == true
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                        size: 20,
                        color: colors.colorGrey,
                      ),
                      const SizedBox(
                        width: 15,
                      ),
                      TextWidget.subText(text: "Start Date",theme: false,color: colors.colorGrey,fw: 0),
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
