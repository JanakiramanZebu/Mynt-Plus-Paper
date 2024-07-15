import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

import '../../../provider/market_watch_provider.dart';
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
  List<String> fliterList = [
    "Scrip - A to Z",
    "Scrip - Z to A",
    "Price - High to Low",
    "Price - Low to High",
    "Per.Chng - High to Low",
    "Per.Chng - Low to High"
  ];

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
            ListView.separated(
              shrinkWrap: true,
              itemCount: fliterList.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                    onTap: () async {
                      await context.read(marketWatchProvider).filterMWScrip(
                          sorting: fliterList[index],
                          wlName: watchlist.wlName,
                          context: context);
                      Navigator.pop(context);
                    },
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    dense: true,
                    title: Text(
                      fliterList[index],
                      style: textStyles.prdText.copyWith(
                          color: theme.isDarkMode &&
                                  watchlist.sortByWL == fliterList[index]
                              ? colors.colorWhite
                              : watchlist.sortByWL == fliterList[index]
                                  ? colors.colorBlack
                                  : colors.colorGrey),
                    ),
                    trailing: SvgPicture.asset(theme.isDarkMode
                        ? watchlist.sortByWL == fliterList[index]
                            ? assets.darkActProductIcon
                            : assets.darkProductIcon
                        : watchlist.sortByWL == fliterList[index]
                            ? assets.actProductIcon
                            : assets.productIcon));
              },
              separatorBuilder: (BuildContext context, int index) {
                return const ListDivider();
              },
            ),
          ],
        ),
      );
    });
  }
}
