import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import '../../../provider/market_watch_provider.dart';
import '../../provider/portfolio_provider.dart';
import '../../provider/thems.dart';
import '../../res/res.dart';
import '../../sharedWidget/custom_drag_handler.dart';
import '../../sharedWidget/list_divider.dart';
import 'create_watchlist.dart';
import 'watchlist_rename.dart';

class WatchlistsBottomSheet extends StatefulWidget {
  final String currentWLName;
  const WatchlistsBottomSheet({super.key, required this.currentWLName});

  @override
  State<WatchlistsBottomSheet> createState() => _WatchlistsBottomSheetState();
}

class _WatchlistsBottomSheetState extends State<WatchlistsBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ScopedReader watch, _) {
      final marketWatch = watch(marketWatchProvider);
      final watchlist = marketWatch.marketWatchlist!.values!;
      final preDefWl = marketWatch.preDefWL;
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
                Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                              "My Watchlist (${watchlist.length >= 10 ? 10 : watchlist.length})",
                              style: textStyles.appBarTitleTxt.copyWith(
                                  color: theme.isDarkMode
                                      ? colors.colorWhite
                                      : colors.colorBlack)),
                          if (watchlist.length - 4 < 10)
                            InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        // int selectedValue = 1;
                                        return CreatewatchList(
                                            wList: watchlist);
                                      });
                                },
                                child: Padding(
                                    padding: const EdgeInsets.all(5),
                                    child: Row(children: [
                                      SvgPicture.asset(assets.addCircleIcon,
                                          color: theme.isDarkMode
                                              ? colors.colorLightBlue
                                              : colors.colorBlue),
                                      const SizedBox(width: 3),
                                      Text("Create New Watchlist",
                                          style: textStyles.textBtn.copyWith(
                                              color: theme.isDarkMode
                                                  ? colors.colorLightBlue
                                                  : colors.colorBlue))
                                    ])))
                        ])),
                const SizedBox(height: 10),

                // Pre-defined watchlist items

                Container(
                    padding: const EdgeInsets.only(left: 16),
                    height: 36,
                    child: ListView.separated(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        scrollDirection: Axis.horizontal,
                        itemCount: preDefWl.length,
                        itemBuilder: (BuildContext context, int index) {
                          return ElevatedButton(
                              onPressed: () async {
                                context
                                    .read(marketWatchProvider)
                                    .changeWlName(preDefWl[index], "Yes");
                                if (preDefWl[index] == "My Stocks") {
                                  // await context
                                  //     .read(portfolioProvider)
                                  //     .fetchHoldings(context,"");
                                  context
                                      .read(portfolioProvider)
                                      .requestWSHoldings(
                                          context: context, isSubscribe: true);
                                } else {
                                  await marketWatch.changeWLScrip(
                                      preDefWl[index], context);
                                }

                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 0),
                                  backgroundColor: theme.isDarkMode
                                      ? widget.currentWLName == preDefWl[index]
                                          ? colors.colorbluegrey
                                          : const Color(0xffB5C0CF)
                                              .withOpacity(.15)
                                      : widget.currentWLName == preDefWl[index]
                                          ? const Color(0xff000000)
                                          : const Color(0xffF1F3F8),
                                  shape: const StadiumBorder()),
                              child: Text(
                                  preDefWl[index] == "My Stocks"
                                      ? preDefWl[index]
                                      : "${preDefWl[index][0]}${preDefWl[index].substring(1)}",
                                  style: textStyles.prdText.copyWith(
                                      color: theme.isDarkMode
                                          ? Color(widget.currentWLName ==
                                                  preDefWl[index]
                                              ? 0xff000000
                                              : 0xffffffff)
                                          : Color(widget.currentWLName ==
                                                  preDefWl[index]
                                              ? 0xffffffff
                                              : 0xff000000))));
                        },
                        separatorBuilder: (BuildContext context, int index) {
                          return const SizedBox(width: 10);
                        })),
                Divider(
                    color: theme.isDarkMode
                        ? colors.darkColorDivider
                        : colors.colorDivider),

// My watchlist items
                ListView.separated(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemCount:
                        watchlist.length - 4 >= 10 ? 10 : watchlist.length - 4,
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                          onTap: () async {
                            // click to switch watch list
                            context
                                .read(marketWatchProvider)
                                .changeWlName(watchlist[index], "No");

                            await marketWatch.changeWLScrip(
                                watchlist[index], context);

                            Navigator.pop(context);
                          },
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 0),
                          dense: true,
                          minLeadingWidth: 22,
                          leading: SvgPicture.asset(theme.isDarkMode
                              ? widget.currentWLName == watchlist[index]
                                  ? assets.darkActProductIcon
                                  : assets.darkProductIcon
                              : widget.currentWLName == watchlist[index]
                                  ? assets.actProductIcon
                                  : assets.productIcon),
                          title: Text(
                              watchlist[index].isEmpty
                                  ? watchlist[index]
                                  : "${watchlist[index][0].toUpperCase()}${watchlist[index].substring(1)}",
                              style: textStyles.prdText.copyWith(
                                  color:
                                      widget.currentWLName != watchlist[index]
                                          ? colors.colorGrey
                                          : theme.isDarkMode
                                              ? colors.colorWhite
                                              : colors.colorBlack)),
                          trailing: watchlist.length > 1
                              ? Row(mainAxisSize: MainAxisSize.min, children: [
                                  // Click to Edit watchlist name
                                  InkWell(
                                      onTap: () async {
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return WatchListRename(
                                                  wlname: watchlist[index]);
                                            });
                                      },
                                      child: const Icon(
                                        Icons.edit_outlined,
                                        color: Color(0xff666666),
                                      )),
                                  const SizedBox(width: 10),
                                  SizedBox(
                                      height: 35,
                                      width: 35,
                                      child: InkWell(
                                          child: const Icon(
                                            Icons.delete_outlined,
                                            color: Color(0xff666666),
                                          ),
                                          onTap: () async {
                                            // Click to Delete watchlist name
                                            await marketWatch.deleteWatchList(
                                                watchlist[index], context);

                                            Navigator.pop(context);
                                          }))
                                ])
                              : Container(width: .2));
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return const ListDivider();
                    }),
                const SizedBox(
                  height: 24,
                )
              ]));
    });
  }
}
