import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../locator/preference.dart';
import '../../../provider/portfolio_provider.dart';
import '../../../provider/thems.dart';
import '../../../res/res.dart';
import '../../../sharedWidget/custom_drag_handler.dart';
import '../../../sharedWidget/list_divider.dart';

class HoldingsScripFilterBottomSheet extends StatefulWidget {
  const HoldingsScripFilterBottomSheet({
    super.key,
  });

  @override
  State<HoldingsScripFilterBottomSheet> createState() =>
      _WatchlistsBottomSheetState();
}

class _WatchlistsBottomSheetState
    extends State<HoldingsScripFilterBottomSheet> {
  Preferences pref = Preferences();
  late bool scripisAscending;
  late bool pricepisAscending;
  late bool qtyisAscending;
  late bool perchangisAscending;
  late bool investbyisAscending;

  @override
  void initState() {
    setState(() {
      scripisAscending = pref.isScripname ?? true;
      pricepisAscending = pref.isPrice ?? true;
      qtyisAscending = pref.isQuantity ?? true;
      perchangisAscending = pref.isPerchang ?? true;
      investbyisAscending = pref.isInvestby ?? true;
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ScopedReader watch, _) {
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
                  Text(
                    "Sort by",
                    style: textStyles.appBarTitleTxt.copyWith(
                        color: theme.isDarkMode
                            ? colors.colorWhite
                            : colors.colorBlack),
                  ),
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
                    context
                        .read(portfolioProvider)
                        .filterHoldings(sorting: "ASC", context: context);
                  } else if (scripisAscending == false) {
                    context
                        .read(portfolioProvider)
                        .filterHoldings(sorting: "DSC", context: context);
                  }

                  scripisAscending = !scripisAscending;
                  pref.setScrip(scripisAscending);
                  Navigator.pop(context);
                });
              },
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 13),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          pref.isScripname == true
                              ? "Scrip - A to Z"
                              : "Scrip - Z to A",
                          style: textStyles.prdText,
                        ),
                        Icon(
                          pref.isScripname == true
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
                        .read(portfolioProvider)
                        .filterHoldings(sorting: "LTPDSC", context: context);
                  } else if (pricepisAscending == false) {
                    context
                        .read(portfolioProvider)
                        .filterHoldings(sorting: "LTPASC", context: context);
                  }

                  pricepisAscending = !pricepisAscending;
                  pref.setPrice(pricepisAscending);
                  Navigator.pop(context);
                });
              },
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 13),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          pref.isPrice == true
                              ? "Price - High to Low"
                              : "Price - Low to High",
                          style: textStyles.prdText,
                        ),
                        Icon(
                          pref.isPrice == true
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
                  if (qtyisAscending == true) {
                    context
                        .read(portfolioProvider)
                        .filterHoldings(sorting: "QTYDSC", context: context);
                  } else if (qtyisAscending == false) {
                    context
                        .read(portfolioProvider)
                        .filterHoldings(sorting: "QTYASC", context: context);
                  }

                  qtyisAscending = !qtyisAscending;
                  pref.setqty(qtyisAscending);
                  Navigator.pop(context);
                });
              },
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 13),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          pref.isQuantity == true
                              ? "Qty - High to Low"
                              : "Qty - Low to High",
                          style: textStyles.prdText,
                        ),
                        Icon(
                          pref.isQuantity == true
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
                  if (perchangisAscending == true) {
                    context
                        .read(portfolioProvider)
                        .filterHoldings(sorting: "PCDESC", context: context);
                  } else if (perchangisAscending == false) {
                    context
                        .read(portfolioProvider)
                        .filterHoldings(sorting: "PCASC", context: context);
                  }

                  perchangisAscending = !perchangisAscending;
                  pref.setPerchnage(perchangisAscending);
                  Navigator.pop(context);
                });
              },
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 13),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          pref.isPerchang == true
                              ? "Per.chng - High to Low"
                              : "Per.chng - Low to High ",
                          style: textStyles.prdText,
                        ),
                        Icon(
                          pref.isPerchang == true
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
                  if (investbyisAscending == true) {
                    context
                        .read(portfolioProvider)
                        .filterHoldings(sorting: "INVDESC", context: context);
                  } else if (investbyisAscending == false) {
                    context
                        .read(portfolioProvider)
                        .filterHoldings(sorting: "INVASC", context: context);
                  }

                  investbyisAscending = !investbyisAscending;
                  pref.setInvestby(investbyisAscending);
                  Navigator.pop(context);
                });
              },
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 13),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          pref.isInvestby == true
                              ? "Inv.by - High to Low"
                              : "Inv.by - Low to High",
                          style: textStyles.prdText,
                        ),
                        Icon(
                          pref.isInvestby == true
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
    });
  }
}
