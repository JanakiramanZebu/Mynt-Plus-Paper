import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../provider/market_watch_provider.dart';
import '../../locator/preference.dart';
import '../../provider/thems.dart';
import '../../res/res.dart';
import '../../sharedWidget/custom_drag_handler.dart';
import '../../sharedWidget/list_divider.dart';

class ScripFilterBottomSheet extends StatefulWidget {
  const ScripFilterBottomSheet({
    super.key,
  });

  @override
  State<ScripFilterBottomSheet> createState() => _WatchlistsBottomSheetState();
}

class _WatchlistsBottomSheetState extends State<ScripFilterBottomSheet> {
  Preferences pref = Preferences();
  late bool scripisAscending;
  late bool pricepisAscending;
  late bool perchangisAscending;

  @override
  void initState() {
    setState(() {
      scripisAscending = pref.isMWScripname ?? true;
      pricepisAscending = pref.isMWPrice ?? true;
      perchangisAscending = pref.isMWPerchang ?? true;
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ScopedReader watch, _) {
      final watchlist = watch(marketWatchProvider);
      final theme = watch(themeProvider);
      return Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: theme.isDarkMode ? Colors.black : Colors.white,
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
                        color: theme.isDarkMode ? Colors.white : Colors.black),
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
                    context.read(marketWatchProvider).filterMWScrip(
                        sorting: "Scrip - A to Z",
                        wlName: watchlist.wlName,
                        context: context);
                  } else if (scripisAscending == false) {
                    context.read(marketWatchProvider).filterMWScrip(
                        sorting: "Scrip - Z to A",
                        wlName: watchlist.wlName,
                        context: context);
                  }

                  scripisAscending = !scripisAscending;
                  pref.setMWScrip(scripisAscending);
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
                          pref.isMWScripname == true
                              ? "Scrip - A to Z"
                              : "Scrip - Z to A",
                          style: textStyles.prdText,
                        ),
                        Icon(
                          pref.isMWScripname == true
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
                    context.read(marketWatchProvider).filterMWScrip(
                        sorting: "Price - High to Low",
                        wlName: watchlist.wlName,
                        context: context);
                  } else if (pricepisAscending == false) {
                    context.read(marketWatchProvider).filterMWScrip(
                        sorting: "Price - Low to High",
                        wlName: watchlist.wlName,
                        context: context);
                  }

                  pricepisAscending = !pricepisAscending;
                  pref.setMWPrice(pricepisAscending);
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
                          pref.isMWPrice == true
                              ? "Price - High to Low"
                              : "Price - Low to High",
                          style: textStyles.prdText,
                        ),
                        Icon(
                          pref.isMWPrice == true
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
                    context.read(marketWatchProvider).filterMWScrip(
                        sorting: "Per.Chng - High to Low",
                        wlName: watchlist.wlName,
                        context: context);
                  } else if (perchangisAscending == false) {
                    context.read(marketWatchProvider).filterMWScrip(
                        sorting: "Per.Chng - Low to High",
                        wlName: watchlist.wlName,
                        context: context);
                  }

                  perchangisAscending = !perchangisAscending;
                  pref.setMWPerchnage(perchangisAscending);
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
                          pref.isMWPerchang == true
                              ? "Per.Chng - High to Low"
                              : "Per.Chng - Low to High",
                          style: textStyles.prdText,
                        ),
                        Icon(
                          pref.isMWPerchang == true
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
