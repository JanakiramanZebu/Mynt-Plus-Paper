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
      return SafeArea(
        child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              color: theme.isDarkMode ? Colors.black : Colors.white,
             border: Border(
                                  top: BorderSide(
                                    color: theme.isDarkMode
                                        ? colors.textSecondaryDark
                                            .withOpacity(0.5)
                                        : colors.colorWhite,
                                  ),
                                  left: BorderSide(
                                    color: theme.isDarkMode
                                        ? colors.textSecondaryDark
                                            .withOpacity(0.5)
                                        : colors.colorWhite,
                                  ),
                                  right: BorderSide(
                                    color: theme.isDarkMode
                                        ? colors.textSecondaryDark
                                            .withOpacity(0.5)
                                        : colors.colorWhite,
                                  ),
                                ),

            ),
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
                                  color: theme.isDarkMode
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
                                            fw: 2,
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
                                  onTap: () async {
                                    // click to switch watch list
                                    ref
                                        .read(marketWatchProvider)
                                        .setCurrentWatchlistPageIndex(index);
            
                                    await ref
                                        .read(marketWatchProvider)
                                        .changeWlName(watchlist[index], "No");
            
                                    await marketWatch.changeWLScrip(
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
                                        ? widget.currentWLName ==
                                                watchlist[index]
                                            ? assets.darkActProductIcon
                                            : assets.darkProductIcon
                                        : widget.currentWLName ==
                                                watchlist[index]
                                            ? assets.actProductIcon
                                            : assets.productIcon),
                                    title: Text(
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
                                                : colors.secondaryLight,
                                        theme: theme.isDarkMode,
                                        fw: widget.currentWLName !=
                                                watchlist[index]
                                            ? null
                                            : 2,
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
                                                      builder: (BuildContext
                                                          context) {
                                                        return WatchListRename(
                                                            wlname: watchlist[
                                                                index]);
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
                                                  highlightColor: theme
                                                          .isDarkMode
                                                      ? Colors.white
                                                          .withOpacity(0.08)
                                                      : Colors.black
                                                          .withOpacity(0.08),
                                                  child: Padding(
                                                    padding: EdgeInsets.all(8),
                                                    child: Icon(
                                                      Icons.edit_outlined,
                                                      color: theme.isDarkMode
                                                          ? colors
                                                              .textSecondaryDark
                                                          : colors
                                                              .textSecondaryLight,
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
                                                      // barrierColor: Colors.black.withOpacity(0.5),
                                                      builder: (BuildContext
                                                          context) {
                                                        return StatefulBuilder(
                                                          builder: (BuildContext
                                                                  context,
                                                              StateSetter
                                                                  setDialogState) {
                                                            return AlertDialog(
                                                              backgroundColor: theme
                                                                      .isDarkMode
                                                                  ? const Color(
                                                                      0xFF121212)
                                                                  : const Color(
                                                                      0xFFF1F3F8),
                                                              titlePadding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          8,
                                                                      vertical:
                                                                          8),
                                                              shape: const RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius.all(
                                                                          Radius.circular(
                                                                              8))),
                                                              scrollable: true,
                                                              contentPadding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                horizontal: 12,
                                                                vertical: 12,
                                                              ),
                                                              actionsPadding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      bottom:
                                                                          16,
                                                                      right: 16,
                                                                      left: 16,
                                                                      top: 8),
                                                              insetPadding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          30,
                                                                      vertical:
                                                                          12),
                                                              title: Column(
                                                                children: [
                                                                  Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .end,
                                                                    children: [
                                                                      Material(
                                                                        color: Colors
                                                                            .transparent,
                                                                        shape:
                                                                            const CircleBorder(),
                                                                        child:
                                                                            InkWell(
                                                                          onTap:
                                                                              () async {
                                                                            await Future.delayed(const Duration(milliseconds: 150));
                                                                            Navigator.pop(context);
                                                                          },
                                                                          borderRadius:
                                                                              BorderRadius.circular(20),
                                                                          splashColor: theme.isDarkMode
                                                                              ? colors.splashColorDark
                                                                              : colors.splashColorLight,
                                                                          highlightColor: theme.isDarkMode
                                                                              ? colors.splashColorDark
                                                                              : colors.splashColorLight,
                                                                          child:
                                                                              Padding(
                                                                            padding:
                                                                                const EdgeInsets.all(6.0),
                                                                            child:
                                                                                Icon(
                                                                              Icons.close_rounded,
                                                                              size: 22,
                                                                              color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  const SizedBox(
                                                                      height:
                                                                          12),
                                                                  SizedBox(
                                                                    width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width,
                                                                    child:
                                                                        Padding(
                                                                      padding: const EdgeInsets
                                                                          .symmetric(
                                                                          horizontal:
                                                                              16),
                                                                      child: TextWidget.subText(
                                                                          text:
                                                                              "Are you sure you want to delete ${watchlist[index]} ?",
                                                                          theme: theme
                                                                              .isDarkMode,
                                                                          color: theme.isDarkMode
                                                                              ? colors.textSecondaryDark
                                                                              : colors.textPrimaryLight,
                                                                          fw: 3,
                                                                          align: TextAlign.center),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              actions: [
                                                                SizedBox(
                                                                  width: double
                                                                      .infinity,
                                                                  child:
                                                                      OutlinedButton(
                                                                    onPressed: (_isDeleting ||
                                                                            marketWatch.loading)
                                                                        ? null
                                                                        : () async {
                                                                            setDialogState(() {
                                                                              _isDeleting = true;
                                                                            });
                                                                            await marketWatch.deleteWatchList(watchlist[index],
                                                                                context);
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
                                                                      minimumSize:
                                                                          const Size(
                                                                              0,
                                                                              45), // width, height
                                                                      side: BorderSide(
                                                                          color:
                                                                              colors.btnOutlinedBorder), // Outline border color
                                                                      shape:
                                                                          RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(5),
                                                                      ),
                                                                      backgroundColor:
                                                                          colors
                                                                              .primaryDark, // Transparent background
                                                                    ),
                                                                    child: (_isDeleting ||
                                                                            marketWatch
                                                                                .loading)
                                                                        ? SizedBox(
                                                                            width:
                                                                                18,
                                                                            height:
                                                                                20,
                                                                            child:
                                                                                CircularProgressIndicator(strokeWidth: 2, color:  colors.colorWhite ),
                                                                          )
                                                                        : TextWidget.titleText(
                                                                            text:
                                                                                "Delete",
                                                                            color:
                                                                                colors.colorWhite,
                                                                            theme: theme.isDarkMode,
                                                                            fw: 2),
                                                                  ),
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
                                                      color:
                                                          colors.kColorRedText,
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
                                              : math.max(
                                                  0, watchlist.length - 4))
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
                                                ? colors.secondaryDark
                                                : colors.secondaryLight)
                                            : theme.isDarkMode
                                                ? colors.textSecondaryDark
                                                : colors.textSecondaryLight,
                                        theme: theme.isDarkMode,
                                        fw: isSelected ? 2 : null,
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
                ])),
      );
    });
  }
}
