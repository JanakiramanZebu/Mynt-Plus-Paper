import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mynt_plus/res/global_state_text.dart';
import '../../../provider/market_watch_provider.dart';
import '../../provider/portfolio_provider.dart';
import '../../provider/thems.dart';
import '../../res/res.dart';
import '../../sharedWidget/custom_drag_handler.dart';
import '../../sharedWidget/list_divider.dart';
import 'create_watchlist.dart';
import 'watchlist_rename.dart';
import 'dart:math' as math;

class WatchlistsBottomSheet extends StatefulWidget {
  final String currentWLName;
  const WatchlistsBottomSheet({super.key, required this.currentWLName});

  @override
  State<WatchlistsBottomSheet> createState() => _WatchlistsBottomSheetState();
}

class _WatchlistsBottomSheetState extends State<WatchlistsBottomSheet> {
  bool _isDeleting = false;

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, WidgetRef ref, _) {
      final marketWatch = ref.watch(marketWatchProvider);
      final watchlist = marketWatch.marketWatchlist!.values!;
      final preDefWl = marketWatch.preDefWL;
      final theme = ref.watch(themeProvider);
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
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: TextWidget.titleText(
                                text: "Manage Watchlist",
                                // (${watchlist.length >= 10 ? 10 : watchlist.length})
                                color:   theme.isDarkMode
                        ? colors.textPrimaryDark
                        : colors.textPrimaryLight,
                                theme: theme.isDarkMode,
                                fw: 1),
                          ),
                          if (watchlist.length - 4 < 10)
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                  onTap: () async {
                                    // Add delay for visual feedback
                                    await Future.delayed(
                                        const Duration(milliseconds: 150));

                                    if (context.mounted) {
                                      Navigator.pop(context);
                                    }
                                    await showModalBottomSheet(
                                        context: context,
                                        useSafeArea: true,
                                        isScrollControlled: true,
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(16)),
                                        ),
                                        builder: (BuildContext context) {
                                          return CreatewatchList(
                                              wList: watchlist);
                                        });
                                  },
                                  borderRadius: BorderRadius.circular(8),
                                  splashColor: theme.isDarkMode
                                      ? Colors.white.withOpacity(0.15)
                                      : Colors.black.withOpacity(0.15),
                                  highlightColor: theme.isDarkMode
                                      ? Colors.white.withOpacity(0.08)
                                      : Colors.black.withOpacity(0.08),
                                  child: Padding(
                                      padding: const EdgeInsets.all(5),
                                      child: Row(children: [
                                        SvgPicture.asset(assets.addCircleIcon,
                                            color: theme.isDarkMode
                                                ? colors.secondaryDark
                                                : colors.secondaryLight),
                                        const SizedBox(width: 3),
                                        TextWidget.subText(
                                            text: "Add Watchlist",
                                            color: theme.isDarkMode
                                                ? colors.secondaryDark
                                                : colors.secondaryLight,
                                            theme: theme.isDarkMode,
                                            ),
                                      ]))),
                            )
                        ])),
                const SizedBox(height: 10),
                Divider(
                  color: theme.isDarkMode
                      ? colors.darkColorDivider
                      : colors.colorDivider,
                  height: 0,
                ),
                Flexible(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height *
                          0.6, // Max 60% of screen height
                    ),
                    child: ListView.separated(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        itemCount: (watchlist.length - 4 >= 10
                                    ? 10
                                    : math.max(0, watchlist.length - 4))
                                .toInt() +
                            preDefWl.length,
                        itemBuilder: (BuildContext context, int index) {
                          // First show custom watchlists
                          if (index <
                              (watchlist.length - 4 >= 10
                                      ? 10
                                      : math.max(0, watchlist.length - 4))
                                  .toInt()) {
                            return Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  // click to switch watch list
                                  ref
                                      .read(marketWatchProvider)
                                      .setCurrentWatchlistPageIndex(index);

                                  ref
                                      .read(marketWatchProvider)
                                      .changeWlName(watchlist[index], "No");

                                  marketWatch.changeWLScrip(
                                      watchlist[index], context);

                                  Navigator.pop(context);
                                },
                                splashColor: theme.isDarkMode
                                    ? Colors.white.withOpacity(0.15)
                                    : Colors.black.withOpacity(0.15),
                                highlightColor: theme.isDarkMode
                                    ? Colors.white.withOpacity(0.08)
                                    : Colors.black.withOpacity(0.08),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 0),
                                  dense: true,
                                  minLeadingWidth: 16,
                                  leading: SvgPicture.asset(theme.isDarkMode
                                      ? widget.currentWLName == watchlist[index]
                                          ? assets.darkActProductIcon
                                          : assets.darkProductIcon
                                      : widget.currentWLName == watchlist[index]
                                          ? assets.actProductIcon
                                          : assets.productIcon),
                                  title:
                                      Text(
                                    watchlist[index].isEmpty
                                        ? watchlist[index]
                                        : watchlist[index] == "My Stocks"
                                            ? "Holdings"
                                            : watchlist[index] == "Nifty50"
                                                ? "Nifty 50"
                                                : watchlist[index] ==
                                                        "Niftybank"
                                                    ? "Nifty Bank"
                                                    : "${watchlist[index][0].toUpperCase()}${watchlist[index].substring(1)}",
                                    style: TextWidget.textStyle(
                                        fontSize: 14,
                                        color: widget.currentWLName !=
                                                watchlist[index] 
                                            ? theme.isDarkMode                               
                                ? colors.textSecondaryDark
                                : colors.textSecondaryLight 
                                            : theme.isDarkMode
                                ? colors.secondaryDark
                                : colors.secondaryLight ,
                                        theme: theme.isDarkMode,
                                        ),
                                  ),
                                  trailing: watchlist.length > 1
                                      ? Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            // Edit button with circular splash
                                            Material(
                                              color: Colors.transparent,
                                              child: InkWell(
                                                onTap: () async {
                                                  // Add delay for visual feedback
                                                  await Future.delayed(
                                                      const Duration(
                                                          milliseconds: 150));

                                                  showModalBottomSheet(
                                                    context: context,
                                                    useSafeArea: true,
                                                    isScrollControlled: true,
                                                    shape:
                                                        const RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.vertical(
                                                              top: Radius
                                                                  .circular(
                                                                      16)),
                                                    ),
                                                    builder:
                                                        (BuildContext context) {
                                                      return WatchListRename(
                                                          wlname:
                                                              watchlist[index]);
                                                    },
                                                  );
                                                },
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                splashColor: theme.isDarkMode
                                                    ? Colors.white
                                                        .withOpacity(0.15)
                                                    : Colors.black
                                                        .withOpacity(0.15),
                                                highlightColor: theme.isDarkMode
                                                    ? Colors.white
                                                        .withOpacity(0.08)
                                                    : Colors.black
                                                        .withOpacity(0.08),
                                                child: const Padding(
                                                  padding: EdgeInsets.all(8),
                                                  child: Icon(
                                                    Icons.edit_outlined,
                                                    color: Color(0xff666666),
                                                    size: 20,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 5),
                                            // Delete button with circular splash
                                            Material(
                                              color: Colors.transparent,
                                              child: InkWell(
                                                onTap: () async {
                                                  // Add delay for visual feedback
                                                  await Future.delayed(
                                                      const Duration(
                                                          milliseconds: 150));

                                                  // Click to Delete watchlist name
                                                  await showDialog(
                                                    context: context,
                                                    barrierDismissible: false,
                                                    builder:
                                                        (BuildContext context) {
                                                      return StatefulBuilder(
                                                        builder: (BuildContext
                                                                context,
                                                            StateSetter
                                                                setDialogState) {
                                                          return AlertDialog(
                                                            backgroundColor: theme
                                                                    .isDarkMode
                                                                ? const Color
                                                                    .fromARGB(
                                                                    255,
                                                                    18,
                                                                    18,
                                                                    18)
                                                                : colors
                                                                    .colorWhite,
                                                            shape: const RoundedRectangleBorder(
                                                                borderRadius: BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            16))),
                                                            scrollable: true,
                                                            actionsPadding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    left: 16,
                                                                    right: 16,
                                                                    bottom: 14,
                                                                    top: 10),
                                                            contentPadding:
                                                                EdgeInsets.zero,
                                                            insetPadding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        16),
                                                            titlePadding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    left: 16,
                                                                    right: 8,
                                                                    top: 0,
                                                                    bottom: 0),
                                                            title: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  TextWidget.titleText(
                                                                      text:
                                                                          "Delete Watchlist",
                                                                          color:  theme.isDarkMode
                        ? colors.textPrimaryDark
                        : colors.textPrimaryLight,
                                                                      theme: theme
                                                                          .isDarkMode,
                                                                      fw: 1),
                                                                  InkWell(
                                                                    onTap: () {
                                                                      Navigator.pop(
                                                                          context);
                                                                    },
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            32), // Makes the ripple circular
                                                                    splashColor: theme
                                                                            .isDarkMode
                                                                        ? Colors
                                                                            .white
                                                                            .withOpacity(
                                                                                0.2)
                                                                        : Colors
                                                                            .black
                                                                            .withOpacity(0.1),
                                                                    highlightColor:
                                                                        Colors
                                                                            .transparent, // Optional: remove highlight if not needed
                                                                    customBorder:
                                                                        const CircleBorder(), // Ensures ripple is circular
                                                                    child:
                                                                        Padding(
                                                                      padding: const EdgeInsets
                                                                          .all(
                                                                          8.0), // Ensures enough space for ripple
                                                                      child:
                                                                          Icon(
                                                                        Icons
                                                                            .close_rounded,
                                                                        size:
                                                                            22,
                                                                        color: theme.isDarkMode
                                                                            ? const Color(0xffBDBDBD)
                                                                            : colors.colorGrey,
                                                                      ),
                                                                    ),
                                                                  )
                                                                ]),
                                                            content: SizedBox(
                                                                width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width,
                                                                child: Column(
                                                                    children: [
                                                                      const ListDivider(),
                                                                      const SizedBox(
                                                                          height:
                                                                              14),
                                                                      Padding(
                                                                        padding: const EdgeInsets
                                                                            .symmetric(
                                                                            horizontal:
                                                                                16),
                                                                        child: TextWidget.subText(
                                                                            text:
                                                                                'Are you sure you want to delete "${watchlist[index]}" ?',
                                                                            theme:
                                                                                theme.isDarkMode,
                                                                            ),
                                                                      ),
                                                                    ])),
                                                            actions: [
                                                              Row(
                                                                children: [
                                                                  Expanded(
                                                                    child:
                                                                        OutlinedButton(
                                                                      onPressed: (_isDeleting ||
                                                                              marketWatch.loading)
                                                                          ? null
                                                                          : () async {
                                                                              setDialogState(() {
                                                                                _isDeleting = true;
                                                                              });
                                                                              await marketWatch.deleteWatchList(watchlist[index], context);
                                                                              if (context.mounted) {
                                                                                await Future.delayed(const Duration(milliseconds: 50));
                                                                                Navigator.pop(context);
                                                                                Navigator.pop(context);
                                                                              }
                                                                              if (mounted) {
                                                                                setDialogState(() {
                                                                                  _isDeleting = false;
                                                                                });
                                                                              }
                                                                            },
                                                                      style: OutlinedButton
                                                                          .styleFrom(
                                                                        minimumSize: const Size(
                                                                            0,
                                                                            40), // width, height
                                                                        side: BorderSide(
                                                                            color:
                                                                                colors.error), // Outline border color
                                                                        shape:
                                                                            RoundedRectangleBorder(
                                                                          borderRadius:
                                                                              BorderRadius.circular(5),
                                                                        ),
                                                                        backgroundColor:
                                                                            Colors.transparent, // Transparent background
                                                                      ),
                                                                      child: (_isDeleting ||
                                                                              marketWatch
                                                                                  .loading)
                                                                          ? const SizedBox(
                                                                              width: 18,
                                                                              height: 20,
                                                                              child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xff666666)),
                                                                            )
                                                                          : TextWidget.subText(
                                                                              text: "Delete",
                                                                              color: colors.error,
                                                                              theme: theme.isDarkMode,
                                                                              fw: 2),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          );
                                                        },
                                                      );
                                                    },
                                                  );
                                                },
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8),
                                                  child: Icon(
                                                    Icons.delete_outlined,
                                                    color: colors.kColorRedText,
                                                    size: 20,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                      : Container(width: .2),
                                ),
                              ),
                            );
                          } else {
                            // Then show pre-defined watchlists
                            final preDefIndex = (index -
                                    (watchlist.length - 4 >= 10
                                            ? 10
                                            : math.max(0, watchlist.length - 4))
                                        .toInt())
                                .toInt();
                            final isSelected =
                                widget.currentWLName == preDefWl[preDefIndex];

                            return Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  ref
                                      .read(marketWatchProvider)
                                      .setCurrentWatchlistPageIndex(
                                          preDefIndex + watchlist.length - 4);
                                  ref.read(marketWatchProvider).changeWlName(
                                      preDefWl[preDefIndex], "Yes");

                                  if (preDefWl[preDefIndex] == "My Stocks") {
                                    ref
                                        .read(portfolioProvider)
                                        .requestWSHoldings(
                                            context: context,
                                            isSubscribe: true);
                                  } else {
                                    marketWatch.changeWLScrip(
                                        preDefWl[preDefIndex], context);
                                  }

                                  if (context.mounted) {
                                    Navigator.pop(context);
                                  }
                                },
                                splashColor: theme.isDarkMode
                                    ? Colors.white.withOpacity(0.15)
                                    : Colors.black.withOpacity(0.15),
                                highlightColor: theme.isDarkMode
                                    ? Colors.white.withOpacity(0.08)
                                    : Colors.black.withOpacity(0.08),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 0),
                                  dense: true,
                                  minLeadingWidth: 16,
                                  leading: SvgPicture.asset(theme.isDarkMode
                                      ? isSelected
                                          ? assets.darkActProductIcon
                                          : assets.darkProductIcon
                                      : isSelected
                                          ? assets.actProductIcon
                                          : assets.productIcon),
                                  title:
                                      // TextWidget.subText(
                                      //     text: preDefWl[preDefIndex] == "My Stocks"
                                      //         ? preDefWl[preDefIndex]
                                      //         : "${preDefWl[preDefIndex][0].toUpperCase()}${preDefWl[preDefIndex].substring(1)}",
                                      //     color: isSelected
                                      //         ? theme.isDarkMode
                                      //             ? colors.colorWhite
                                      //             : colors.colorBlack
                                      //         : colors.colorGrey,
                                      //     theme: theme.isDarkMode,
                                      //     fw: 0),

                                      Text(
                                    preDefWl[preDefIndex] == "My Stocks"
                                        ? "Holdings"
                                        : preDefWl[preDefIndex] == "Nifty50"
                                            ? "Nifty 50"
                                            : preDefWl[preDefIndex] ==
                                                    "Niftybank"
                                                ? "Nifty Bank"
                                                : "${preDefWl[preDefIndex][0].toUpperCase()}${preDefWl[preDefIndex].substring(1)}",
                                    style: TextWidget.textStyle(
                                      fontSize: 14,
                                      color: isSelected
                                          ? (theme.isDarkMode
                                              ? colors.colorWhite
                                              : colors.colorBlack)
                                          : colors.colorGrey,
                                      theme: theme.isDarkMode,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }
                        },
                        separatorBuilder: (BuildContext context, int index) {
                          return const ListDivider();
                        }),
                  ),
                ),
                const SizedBox(
                  height: 24,
                )
              ]));
    });
  }
}
