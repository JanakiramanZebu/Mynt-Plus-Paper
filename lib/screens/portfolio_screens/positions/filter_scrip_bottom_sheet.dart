import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../locator/preference.dart';
import '../../../provider/portfolio_provider.dart';
import '../../../provider/thems.dart';
import '../../../res/global_state_text.dart';
import '../../../res/res.dart';
import '../../../sharedWidget/custom_drag_handler.dart';
import '../../../sharedWidget/list_divider.dart';

class PositionScripFilterBottomSheet extends StatefulWidget {
  const PositionScripFilterBottomSheet({
    super.key,
  });

  @override
  State<PositionScripFilterBottomSheet> createState() =>
      _PositionScripBottomSheetState();
}

class _PositionScripBottomSheetState
    extends State<PositionScripFilterBottomSheet> {
  Preferences pref = Preferences();
  late bool scripisAscending;
  late bool pricepisAscending;
  late bool qtyisAscending;
  late bool perchangisAscending;
  late bool postion;

  @override
  void initState() {
    setState(() {
      scripisAscending = pref.isPosScripname ?? true;
      pricepisAscending = pref.isPosPrice ?? true;
      qtyisAscending = pref.isPosQuantity ?? true;
      perchangisAscending = pref.isPosPerchang ?? true;
      postion = pref.isPostion ?? true;
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, WidgetRef ref, _) {
      // final watchlist = ref.watch(marketWatchProvider);
      final theme = ref.read(themeProvider);
      return SafeArea(
        child: Container(
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
                    TextWidget.titleText(
                        text: "Sort by",
                        theme: false,
                        color: theme.isDarkMode
                            ? colors.colorWhite
                            : colors.colorBlack,
                        fw: 1),
                  ],
                ),
              ),
              Divider(
                  color: theme.isDarkMode
                      ? colors.darkColorDivider
                      : colors.colorDivider),
              InkWell(
                onTap: () {
                  setState(() {
                    if (scripisAscending == true) {
                      ref.read(portfolioProvider).sortPositions(sorting: "ASC");
                    } else if (scripisAscending == false) {
                      ref.read(portfolioProvider).sortPositions(sorting: "DSC");
                    }

                    scripisAscending = !scripisAscending;
                    pref.setPosScrip(scripisAscending);
                    Navigator.pop(context);
                  });
                },
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 13),
                      child: Row(
                        children: [
                          Icon(
                            pref.isPosScripname == true
                                ? Icons.arrow_upward
                                : Icons.arrow_downward,
                            size: 20,
                            color: colors.colorGrey,
                          ),
                          const SizedBox(
                            width: 15,
                          ),
                          TextWidget.subText(
                              text: "Scrip Name",
                              theme: false,
                              color: colors.colorGrey,
                              fw: 0),
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
                      ref
                          .read(portfolioProvider)
                          .sortPositions(sorting: "LTPDSC");
                    } else if (pricepisAscending == false) {
                      ref
                          .read(portfolioProvider)
                          .sortPositions(sorting: "LTPASC");
                    }

                    pricepisAscending = !pricepisAscending;
                    pref.setPosPrice(pricepisAscending);
                    Navigator.pop(context);
                  });
                },
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 13),
                      child: Row(
                        children: [
                          Icon(
                            pref.isPosPrice == true
                                ? Icons.arrow_upward
                                : Icons.arrow_downward,
                            size: 20,
                            color: colors.colorGrey,
                          ),
                          const SizedBox(
                            width: 15,
                          ),
                          TextWidget.subText(
                              text: "LTP",
                              theme: false,
                              color: colors.colorGrey,
                              fw: 0),
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
                      ref
                          .read(portfolioProvider)
                          .sortPositions(sorting: "QTYDSC");
                    } else if (qtyisAscending == false) {
                      ref
                          .read(portfolioProvider)
                          .sortPositions(sorting: "QTYASC");
                    }

                    qtyisAscending = !qtyisAscending;
                    pref.setPosqty(qtyisAscending);
                    Navigator.pop(context);
                  });
                },
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 13),
                      child: Row(
                        children: [
                          Icon(
                            pref.isPosQuantity == true
                                ? Icons.arrow_upward
                                : Icons.arrow_downward,
                            size: 20,
                            color: colors.colorGrey,
                          ),
                          SizedBox(
                            width: 15,
                          ),
                          TextWidget.subText(
                              text: "Qty",
                              theme: false,
                              color: colors.colorGrey,
                              fw: 0),
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
                    if (perchangisAscending == true) {
                      ref
                          .read(portfolioProvider)
                          .sortPositions(sorting: "PCDESC");
                    } else if (perchangisAscending == false) {
                      ref
                          .read(portfolioProvider)
                          .sortPositions(sorting: "PCASC");
                    }

                    perchangisAscending = !perchangisAscending;
                    pref.setPosPerchnage(perchangisAscending);
                    Navigator.pop(context);
                  });
                },
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 13),
                      child: Row(
                        children: [
                          Icon(
                            pref.isPosPerchang == true
                                ? Icons.arrow_upward
                                : Icons.arrow_downward,
                            size: 20,
                            color: colors.colorGrey,
                          ),
                          const SizedBox(
                            width: 15,
                          ),
                          TextWidget.subText(
                              text: "Perc.Change",
                              theme: false,
                              color: colors.colorGrey,
                              fw: 0),
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
                    if (postion == true) {
                      ref
                          .read(portfolioProvider)
                          .sortPositions(sorting: "Open");
                    } else if (postion == false) {
                      ref
                          .read(portfolioProvider)
                          .sortPositions(sorting: "Close");
                    }

                    postion = !postion;
                    pref.setPostion(postion);
                    Navigator.pop(context);
                  });
                },
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 13),
                      child: Row(
                        children: [
                          Icon(
                            pref.isPostion == true
                                ? Icons.arrow_upward
                                : Icons.arrow_downward,
                            size: 20,
                            color: colors.colorGrey,
                          ),
                          const SizedBox(
                            width: 15,
                          ),
                          TextWidget.subText(
                              text: pref.isPostion == true
                                  ? "Open Position"
                                  : "Close Position",
                              theme: false,
                              color: colors.colorGrey,
                              fw: 0),
                        ],
                      ),
                    ),
                    const ListDivider(),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
