import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../locator/preference.dart';
import '../../../provider/portfolio_provider.dart';
import '../../../provider/thems.dart';
import '../../../res/global_state_text.dart';
import '../../../res/res.dart';
import '../../../sharedWidget/custom_drag_handler.dart';
import '../../../sharedWidget/list_divider.dart';

class MFHoldingsScripFilterBottomSheet extends StatefulWidget {
  const MFHoldingsScripFilterBottomSheet({
    super.key,
  });

  @override
  State<MFHoldingsScripFilterBottomSheet> createState() =>
      _MFHoldingsScripFilterBottomSheetState();
}

class _MFHoldingsScripFilterBottomSheetState
    extends State<MFHoldingsScripFilterBottomSheet> {
  Preferences pref = Preferences();
  late bool scripisAscending;
  late bool pricepisAscending;
  late bool qtyisAscending;
  late bool perchangisAscending;
  late bool investbyisAscending;

  @override
  void initState() {
    setState(() {
      scripisAscending = pref.isMfScripname ?? true;
      pricepisAscending = pref.isMfPrice ?? true;
      qtyisAscending = pref.isMfQuantity ?? true;
      perchangisAscending = pref.isMfPerchang ?? true;
      investbyisAscending = pref.isMfInvestby ?? true;
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, WidgetRef ref, _) {
      // final watchlist = ref.watch(marketWatchProvider);
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
                  TextWidget.titleText(
                      text: "Sort by", theme: theme.isDarkMode, fw: 1),
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
                    ref
                        .read(portfolioProvider)
                        .filterMfHoldings(sorting: "ASC", context: context);
                  } else if (scripisAscending == false) {
                    ref
                        .read(portfolioProvider)
                        .filterMfHoldings(sorting: "DSC", context: context);
                  }

                  scripisAscending = !scripisAscending;
                  pref.setMfScrip(scripisAscending);
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
                          pref.isMfScripname == true
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
                            theme: theme.isDarkMode,
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
                        .filterMfHoldings(sorting: "LTPDSC", context: context);
                  } else if (pricepisAscending == false) {
                    ref
                        .read(portfolioProvider)
                        .filterMfHoldings(sorting: "LTPASC", context: context);
                  }

                  pricepisAscending = !pricepisAscending;
                  pref.setMfPrice(pricepisAscending);
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
                          pref.isMfPrice == true
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
                            theme: theme.isDarkMode,
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
                        .filterMfHoldings(sorting: "QTYDSC", context: context);
                  } else if (qtyisAscending == false) {
                    ref
                        .read(portfolioProvider)
                        .filterMfHoldings(sorting: "QTYASC", context: context);
                  }

                  qtyisAscending = !qtyisAscending;
                  pref.setMfqty(qtyisAscending);
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
                          pref.isMfQuantity == true
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                          size: 20,
                          color: colors.colorGrey,
                        ),
                        const SizedBox(
                          width: 15,
                        ),
                        TextWidget.subText(
                            text: "Qty",
                            theme: theme.isDarkMode,
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
                        .filterMfHoldings(sorting: "PCDESC", context: context);
                  } else if (perchangisAscending == false) {
                    ref
                        .read(portfolioProvider)
                        .filterMfHoldings(sorting: "PCASC", context: context);
                  }

                  perchangisAscending = !perchangisAscending;
                  pref.setMfPerchnage(perchangisAscending);
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
                          pref.isMfPerchang == true
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
                            theme: theme.isDarkMode,
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
                  if (investbyisAscending == true) {
                    ref
                        .read(portfolioProvider)
                        .filterMfHoldings(sorting: "INVDESC", context: context);
                  } else if (investbyisAscending == false) {
                    ref
                        .read(portfolioProvider)
                        .filterMfHoldings(sorting: "INVASC", context: context);
                  }

                  investbyisAscending = !investbyisAscending;
                  pref.setMfInvestby(investbyisAscending);
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
                          pref.isMfInvestby == true
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                          size: 20,
                          color: colors.colorGrey,
                        ),
                        const SizedBox(
                          width: 15,
                        ),
                        TextWidget.subText(
                            text: "Invested Price",
                            theme: theme.isDarkMode,
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
      );
    });
  }
}
