import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';

import '../../../../models/order_book_model/order_book_model.dart';
import '../../../../provider/market_watch_provider.dart';
import '../../../../provider/order_provider.dart';
import '../../../../provider/thems.dart';
import '../../../../provider/websocket_provider.dart';
import '../../../../res/global_state_text.dart';
import '../../../../res/res.dart';
import '../../../../routes/route_names.dart';
import '../../../../sharedWidget/custom_back_btn.dart';
import '../../../../sharedWidget/functions.dart';
import '../../../../sharedWidget/list_divider.dart';
import '../../../../sharedWidget/no_data_found.dart';
import 'create_basket.dart';

class BasketList extends ConsumerWidget {
  const BasketList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final basket = ref.watch(orderProvider);
    final theme = ref.watch(themeProvider);
    bool _isDeleting = false;

    print("=== BASKET LIST BUILD ===");
    print("isBasketLoading: ${basket.isBasketLoading}");
    print("bsktList.length: ${basket.bsktList.length}");
    print("bsktList.isEmpty: ${basket.bsktList.isEmpty}");
    print("bsktList content: ${basket.bsktList}");
    print("========================");

    return Column(
      children: [
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: theme.isDarkMode
                      ? colors.textSecondaryDark.withOpacity(0.6)
                      : colors.btnBg,
                  borderRadius: BorderRadius.circular(5),
                  border: theme.isDarkMode
                      ? null
                      : Border.all(color: colors.btnOutlinedBorder, width: 1),
                ),
                child: Material(
                  color: Colors.transparent,
                  shape: const BeveledRectangleBorder(),
                  child: InkWell(
                      customBorder: const BeveledRectangleBorder(),
                      splashColor: theme.isDarkMode
                          ? colors.splashColorDark
                          : colors.splashColorLight,
                      highlightColor: theme.isDarkMode
                          ? colors.highlightDark
                          : colors.highlightLight,
                      onTap: () {
                        Future.delayed(const Duration(milliseconds: 150), () {
                          showModalBottomSheet(
                              context: context,
                              useSafeArea: true,
                              isScrollControlled: true,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(16)),
                              ),
                              builder: (BuildContext context) {
                                return const CreateBasket();
                              });
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        child: TextWidget.subText(
                            text: "Create Basket",
                            theme: theme.isDarkMode,
                            color: theme.isDarkMode
                                ? colors.colorWhite
                                : colors.primaryLight,
                            fw: 2),
                      )),
                ),
              ),
            ],
          ),
        ),
        basket.isBasketLoading
            ? const SizedBox(
                height: 400, child: Center(child: CircularProgressIndicator()))
            : basket.bsktList.isEmpty
                ? const SizedBox(height: 400, child: NoDataFound())
                : Expanded(
                    child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: basket.bsktList.length,
                      itemBuilder: (BuildContext context, int index) {
                        final bsktName = basket.bsktList[index]['bsketName'];

                        return ListTile(
                          dense: false,
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 16),
                          onLongPress: () {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext context) {
                                return StatefulBuilder(
                                  builder: (BuildContext context,
                                      StateSetter setDialogState) {
                                    return AlertDialog(
                                      backgroundColor: colors.colorWhite,
                                      titlePadding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 8),
                                      shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(8))),
                                      scrollable: true,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 12),
                                      actionsPadding: const EdgeInsets.only(
                                          bottom: 16,
                                          right: 16,
                                          left: 16,
                                          top: 8),
                                      insetPadding: const EdgeInsets.symmetric(
                                          horizontal: 30, vertical: 12),
                                      title: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              Material(
                                                color: Colors.transparent,
                                                shape: const CircleBorder(),
                                                child: InkWell(
                                                  onTap: () =>
                                                      Navigator.pop(context),
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  splashColor: theme.isDarkMode
                                                      ? colors.splashColorDark
                                                      : colors.splashColorLight,
                                                  highlightColor: theme
                                                          .isDarkMode
                                                      ? colors.splashColorDark
                                                      : colors.splashColorLight,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            6.0),
                                                    child: Icon(
                                                      Icons.close_rounded,
                                                      size: 22,
                                                      color: theme.isDarkMode
                                                          ? const Color(
                                                              0xffBDBDBD)
                                                          : colors.colorGrey,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          SizedBox(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                const SizedBox(height: 5),
                                                TextWidget.subText(
                                                  text:
                                                      "Are you sure you want to delete this basket ${bsktName.toString().toUpperCase()}?",
                                                  theme: theme.isDarkMode,
                                                  color: theme.isDarkMode
                                                      ? colors.textPrimaryDark
                                                      : colors.textPrimaryLight,
                                                  fw: 3,
                                                  align: TextAlign.center,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      actions: [
                                        SizedBox(
                                          width: double.infinity,
                                          child: OutlinedButton(
                                            onPressed: _isDeleting
                                                ? null
                                                : () async {
                                                    setDialogState(() {
                                                      _isDeleting = true;
                                                    });
                                                    Navigator.pop(context);
                                                    await basket
                                                        .removeBasket(index);
                                                    if (context.mounted) {
                                                      setDialogState(() {
                                                        _isDeleting = false;
                                                      });
                                                    }
                                                  },
                                            style: OutlinedButton.styleFrom(
                                              minimumSize: const Size(0, 40),
                                              side: BorderSide(
                                                  color:
                                                      colors.btnOutlinedBorder),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                              ),
                                              backgroundColor:
                                                  colors.primaryDark,
                                            ),
                                            child: _isDeleting
                                                ? SizedBox(
                                                    width: 18,
                                                    height: 20,
                                                    child:
                                                        CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      color: theme.isDarkMode
                                                          ? colors
                                                              .textSecondaryDark
                                                          : colors
                                                              .textSecondaryLight,
                                                    ),
                                                  )
                                                : TextWidget.titleText(
                                                    text: "Delete",
                                                    theme: theme.isDarkMode,
                                                    color: !theme.isDarkMode
                                                        ? colors.colorWhite
                                                        : colors.colorBlack,
                                                    fw: 0,
                                                  ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            );
                          },
                          onTap: () async {
                            await basket.fetchBasketMargin();
                            basket.chngBsktName(
                                basket.bsktList[index]['bsketName'],
                                context,
                                false);
                          },
                          minLeadingWidth: 25,
                          leading: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                assets.basketdashboard,
                                color: theme.isDarkMode
                                    ? colors.textSecondaryDark
                                    : colors.textSecondaryLight,
                              ),
                            ],
                          ),
                          title: Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: TextWidget.subText(
                              text: bsktName,
                              theme: false,
                              color: theme.isDarkMode
                                  ? colors.textPrimaryDark
                                  : colors.textPrimaryLight,
                              fw: 0,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Row(
                              children: [
                                TextWidget.paraText(
                                  text:
                                      "${basket.bsktList[index]['createdDate']}",
                                  theme: false,
                                  color: theme.isDarkMode
                                      ? colors.textSecondaryDark
                                      : colors.textSecondaryLight,
                                  fw: 0,
                                ),
                                // const SizedBox(width: 4),
                                // TextWidget.paraText(
                                //   text:
                                //       " - ${basket.bsktList[index]['curLength']} items",
                                //   theme: false,
                                //   color: colors.textPrimary,
                                // ),
                              ],
                            ),
                          ),
                          trailing: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: theme.isDarkMode
                                    ? colors.textSecondaryDark
                                    : colors.textPrimaryLight,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: TextWidget.paraText(
                              text: "${basket.bsktList[index]['curLength']}",
                              theme: false,
                              color: theme.isDarkMode
                                  ? colors.textSecondaryDark
                                  : colors.textPrimaryLight,
                              fw: 0,
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) {
                        return const ListDivider();
                      },
                    ),
                  ),
      ],
    );
  }
}

class BasketScripList extends ConsumerWidget {
  final String bsktName;
  const BasketScripList({super.key, required this.bsktName});

  /// Checks if the basket contains scripts from multiple exchanges
  bool _hasMultipleExchanges(List scriptList) {
    if (scriptList.isEmpty) return false;

    // Extract all exchanges from the basket scripts
    Set<String> exchanges = {};
    for (var script in scriptList) {
      if (script['exch'] != null) {
        exchanges.add(script['exch'].toString());
      }
    }

    // If there's more than one unique exchange, return true
    return exchanges.length > 1;
  }

  /// Checks if the current basket has any orders placed
  bool _hasOrdersPlacedInBasket(
      String basketName, OrderProvider orderProvider) {
    // Check if this basket has any order tracking
    return orderProvider.basketOrderIds.containsKey(basketName) &&
        orderProvider.basketOrderIds[basketName]!.isNotEmpty;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.read(themeProvider);
    final basket = ref.watch(orderProvider);

    return Scaffold(
        appBar: AppBar(
            elevation: .2,
            leadingWidth: 41,
            centerTitle: false,
            titleSpacing: 6,
            leading: const CustomBackBtn(),
            title: TextWidget.titleText(
                text:
                    "${bsktName}   (${basket.bsktScripList.length} / ${basket.frezQtyOrderSliceMaxLimit})",
                theme: false,
                color: theme.isDarkMode
                    ? colors.textPrimaryDark
                    : colors.textPrimaryLight,
                fw: 1),
            actions: basket.bsktScripList.length < basket.frezQtyOrderSliceMaxLimit
                ? [
                    Row(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(right: 16),
                          decoration: BoxDecoration(
                            color: theme.isDarkMode
                                ? colors.textSecondaryDark.withOpacity(0.6)
                                : colors.btnBg,
                            borderRadius: BorderRadius.circular(5),
                            border: theme.isDarkMode
                                ? null
                                : Border.all(
                                    color: colors.btnOutlinedBorder,
                                    width: 1),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            shape: const BeveledRectangleBorder(),
                            child: InkWell(
                                customBorder: const BeveledRectangleBorder(),
                                splashColor: theme.isDarkMode
                                    ? colors.splashColorDark
                                    : colors.splashColorLight,
                                highlightColor: theme.isDarkMode
                                    ? colors.highlightDark
                                    : colors.highlightLight,
                                onTap: () async {
                                  // Check if basket already has frezQtyOrderSliceMaxLimit items
                                  if (basket.bsktScripList.length >= basket.frezQtyOrderSliceMaxLimit) {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                      content: Text(
                                          "Basket limit reached. Please create a new basket as you are exceeding the ${basket.frezQtyOrderSliceMaxLimit} item limit."),
                                      backgroundColor: colors.darkred,
                                      duration: const Duration(seconds: 3),
                                    ));
                                    return;
                                  }
    
                                  await ref
                                      .watch(marketWatchProvider)
                                      .searchClear();
                                  Navigator.pushNamed(
                                      context, Routes.searchScrip,
                                      arguments: "Basket");
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  child: TextWidget.subText(
                                      text: "Add symbol",
                                      theme: theme.isDarkMode,
                                      color: theme.isDarkMode
                                          ? colors.colorWhite
                                          : colors.primaryLight,
                                      fw: 2),
                                )),
                          ),
                        ),
                      ],
                    ),
                  ]
                : null),
        body: SafeArea(
          child: Column(children: [
            Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Margin Information Row
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextWidget.subText(
                                  text: "Pre Trade Margin",
                                  theme: false,
                                  color: theme.isDarkMode
                                      ? colors.textSecondaryDark
                                      : colors.textSecondaryLight,
                                  fw: 0,
                                ),
                                const SizedBox(height: 6),
                                TextWidget.subText(
                                  text: basket.bsktScripList.isEmpty ||
                                          basket.bsktOrderMargin == null
                                      ? "0.00"
                                      : (double.parse(basket.bsktOrderMargin!.marginused ?? '0.00') - double.parse(basket.bsktOrderMargin!.marginusedprev ?? '0.00')).toStringAsFixed(2),
                                  color: theme.isDarkMode
                                      ? colors.textPrimaryDark
                                      : colors.textPrimaryLight,
                                  theme: theme.isDarkMode,
                                  fw: 0,
                                ),
                              ],
                            ),
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  TextWidget.subText(
                                    text: "Post Trade Margin",
                                    theme: false,
                                    color: theme.isDarkMode
                                        ? colors.textSecondaryDark
                                        : colors.textSecondaryLight,
                                    fw: 0,
                                  ),
                                  const SizedBox(height: 6),
                                  TextWidget.subText(
                                    text: basket.bsktScripList.isEmpty ||
                                            basket.bsktOrderMargin == null
                                        ? "0.00"
                                        : (double.parse(basket.bsktOrderMargin!.marginusedtrade ?? '0.00') - double.parse(basket.bsktOrderMargin!.marginusedprev ?? '0.00')).toStringAsFixed(2),
                                    theme: theme.isDarkMode,
                                    color: theme.isDarkMode
                                        ? colors.textPrimaryDark
                                        : colors.textPrimaryLight,
                                    fw: 0,
                                  ),
                                ])
                          ]),
                    ])),
            Container(
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: theme.isDarkMode ? colors.primaryDark.withOpacity(0.3) : colors.primaryLight.withOpacity(0.3),
                  // color: const Color(0xffe3f2fd),
                ),
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  SvgPicture.asset(assets.dInfo, color: colors.colorBlue),
                  TextWidget.paraText(
                    text: " On Script Tap to edit / long press to delete.",
                    theme: false,
                    color: theme.isDarkMode
                        ? colors.secondaryDark
                        : colors.secondaryLight,
                    fw: 0,
                  ),
                ])),
            Expanded(
                child: basket.bsktScripList.isEmpty
                    ? const NoDataFound()
                    : StreamBuilder<Map>(
                        stream: ref.watch(websocketProvider).socketDataStream,
                        builder: (context, snapshot) {
                          final socketDatas = snapshot.data ?? {};
              
                          // Check if we have socket data and need to update
                          if (snapshot.hasData && socketDatas.isNotEmpty) {
                            bool updated = false;
              
                            // Update basket script list with real-time values
                            for (var script in basket.bsktScripList) {
                              final token = script['token']?.toString();
                              if (token != null &&
                                  socketDatas.containsKey(token)) {
                                final lp = socketDatas[token]['lp']?.toString();
                                final pc = socketDatas[token]['pc']?.toString();
              
                                if (lp != null && lp != "null") {
                                  if (script['lp']?.toString() != lp) {
                                    script['lp'] = lp;
                                    updated = true;
                                  }
                                }
              
                                if (pc != null && pc != "null") {
                                  if (script['pc']?.toString() != pc) {
                                    script['pc'] = pc;
                                    updated = true;
                                  }
                                }
                              }
                            }
              
                            // Force a refresh if we have updates
                            if (updated) {
                              // Update in the next frame to avoid rebuild conflicts
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (context.mounted) {
                                  // This will trigger a rebuild with the new values
                                  basket.notifyBasketUpdates();
                                }
                              });
                            }
                          }
              
                          return ListView.separated(
                            shrinkWrap: true,
                            itemCount: basket.bsktScripList.length,
                            separatorBuilder: (_, __) => const ListDivider(),
                            itemBuilder: (BuildContext context, int index) {
                              if (basket.bsktScripList[index]['exch'] ==
                                      "BFO" &&
                                  basket.bsktScripList[index]["dname"] !=
                                      "null") {
                                List<String> splitVal = basket
                                    .bsktScripList[index]["dname"]
                                    .toString()
                                    .split(" ");
              
                                basket.bsktScripList[index]['symbol'] =
                                    splitVal[0];
                                basket.bsktScripList[index]['expDate'] =
                                    "${splitVal[1]} ${splitVal[2]}";
                                basket.bsktScripList[index]['option'] =
                                    splitVal.length > 4
                                        ? "${splitVal[3]} ${splitVal[4]}"
                                        : splitVal[3];
                              } else {
                                Map spilitSymbol = spilitTsym(
                                    value:
                                        "${basket.bsktScripList[index]['tsym']}");
              
                                basket.bsktScripList[index]['symbol'] =
                                    "${spilitSymbol["symbol"]}";
                                basket.bsktScripList[index]['expDate'] =
                                    "${spilitSymbol["expDate"]}";
                                basket.bsktScripList[index]['option'] =
                                    "${spilitSymbol["option"]}";
                              }
              
                              return InkWell(
                                onLongPress: () async {
                                  showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                             backgroundColor: theme
                                                                        .isDarkMode
                                                                    ? const Color(
                                                                        0xFF121212)
                                                                    : const Color(
                                                                        0xFFF1F3F8),
                                            titlePadding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 8, vertical: 8),
                                            shape: const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(8)),
                                            ),
                                            scrollable: true,
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 12),
                                            actionsPadding:
                                                const EdgeInsets.only(
                                                    bottom: 16,
                                                    right: 16,
                                                    left: 16,
                                                    top: 8),
                                            insetPadding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 30,
                                                    vertical: 12),
                                            title: Column(
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    Material(
                                                      color: Colors.transparent,
                                                      shape:
                                                          const CircleBorder(),
                                                      child: InkWell(
                                                        onTap: () async {
                                                          await Future.delayed(
                                                              const Duration(
                                                                  milliseconds:
                                                                      150));
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20),
                                                        splashColor: theme
                                                                .isDarkMode
                                                            ? colors
                                                                .splashColorDark
                                                            : colors
                                                                .splashColorLight,
                                                        highlightColor: theme
                                                                .isDarkMode
                                                            ? colors
                                                                .splashColorDark
                                                            : colors
                                                                .splashColorLight,
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(6.0),
                                                          child: Icon(
                                                            Icons.close_rounded,
                                                            size: 22,
                                                              color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 12),
                                                SizedBox(
                                                    width:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                    child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          TextWidget.subText(
                                                              text:
                                                                  "Are you sure you want to delete this basket Script ${basket.bsktScripList[index]['symbol']?.replaceAll("-EQ", "")}",
                                                              theme: theme
                                                                  .isDarkMode,
                                                              fw: 0,
                                                              color: theme.isDarkMode
                                                                                ? colors.textSecondaryDark
                                                                                : colors.textPrimaryLight,
                                                              align: TextAlign
                                                                  .center),
                                                        ]))
                                              ],
                                            ),
                                            actions: [
                                              SizedBox(
                                                width: double.infinity,
                                                child: OutlinedButton(
                                                  onPressed: () async {
                                                    await basket
                                                        .removeBsktScrip(
                                                            index, bsktName);
                                                    await basket
                                                        .fetchBasketMargin();
                                                    Navigator.pop(context);
                                                  },
                                                  style:
                                                      OutlinedButton.styleFrom(
                                                    minimumSize:
                                                        const Size(0, 45),
                                                    side: BorderSide(
                                                        color: colors
                                                            .btnOutlinedBorder),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                    ),
                                                    backgroundColor:
                                                        colors.primaryDark,
                                                  ),
                                                  child: TextWidget.titleText(
                                                    text: "Yes",
                                                    theme: theme.isDarkMode,
                                                    color:  colors.colorWhite,
                                                    fw: 2,
                                                  ),
                                                ),
                                              ),
                                            ]);
                                      });
                                },
                                onTap: () async {
                                  await ref.read(marketWatchProvider).fetchScripInfo(
                                      "${basket.bsktScripList[index]['token']}",
                                      '${basket.bsktScripList[index]['exch']}',
                                      context,
                                      true);
                                  basket.bsktScripList[index]['index'] = index;
                                  basket.bsktScripList[index]['prctyp'] =
                                      basket.bsktScripList[index]['prctype'];
              
                                  // Ensure lp and pc values are not null for OrderScreenArgs
                                  final ltp = basket.bsktScripList[index]['lp']
                                          ?.toString() ??
                                      "0.00";
                                  final perChange = basket.bsktScripList[index]
                                              ['pc']
                                          ?.toString() ??
                                      "0.00";
              
                                  OrderScreenArgs orderArgs = OrderScreenArgs(
                                      exchange:
                                          '${basket.bsktScripList[index]['exch']}',
                                      tSym:
                                          '${basket.bsktScripList[index]['tsym']}',
                                      isExit: false,
                                      token:
                                          "${basket.bsktScripList[index]['token']}",
                                      transType: basket.bsktScripList[index]
                                                  ['trantype'] ==
                                              'B'
                                          ? true
                                          : false,
                                      lotSize: ref
                                          .read(marketWatchProvider)
                                          .scripInfoModel
                                          ?.ls
                                          .toString(),
                                      ltp: ltp,
                                      perChange: perChange,
                                      orderTpye: '',
                                      holdQty: '',
                                      isModify: true,
                                      prd: basket.bsktScripList[index]['prd']
                                          ?.toString(),
                                      raw: basket.bsktScripList[index]);
                                  Navigator.pushNamed(
                                      context, Routes.placeOrderScreen,
                                      arguments: {
                                        "orderArg": orderArgs,
                                        "scripInfo": ref
                                            .read(marketWatchProvider)
                                            .scripInfoModel!,
                                        "isBskt": 'BasketEdit'
                                      });
                                },
                                child: Container(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Row(children: [
                                                  TextWidget.subText(
                                                      text:
                                                          "${basket.bsktScripList[index]['symbol'].replaceAll("-EQ", "")} ",
                                                      color: theme.isDarkMode
                                                          ? colors
                                                              .textPrimaryDark
                                                          : colors
                                                              .textPrimaryLight,
                                                      theme: theme.isDarkMode,
                                                      fw: 0,
                                                      textOverflow: TextOverflow
                                                          .ellipsis),
                                                  TextWidget.subText(
                                                      text:
                                                          "${basket.bsktScripList[index]['expDate']} ",
                                                      theme: theme.isDarkMode,
                                                      color: theme.isDarkMode
                                                          ? colors
                                                              .textPrimaryDark
                                                          : colors
                                                              .textPrimaryLight,
                                                      fw: 0,
                                                      textOverflow: TextOverflow
                                                          .ellipsis),
                                                  // const SizedBox(width: 4),
                                                  TextWidget.subText(
                                                      text:
                                                          "${basket.bsktScripList[index]['option']} ",
                                                      theme: theme.isDarkMode,
                                                      color: theme.isDarkMode
                                                          ? colors
                                                              .textPrimaryDark
                                                          : colors
                                                              .textPrimaryLight,
                                                      fw: 0,
                                                      textOverflow: TextOverflow
                                                          .ellipsis),
                                                ]),
                                                if (basket.bsktScripList[index]
                                                        ['orderStatus'] !=
                                                    null) ...[
                                                  Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 8,
                                                        vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: _getItemStatusColor(
                                                              basket.bsktScripList[
                                                                      index][
                                                                  'orderStatus'], theme)
                                                          .withOpacity(0.1),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              4),
                                                    ),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        // Icon(
                                                        //   _getItemStatusIcon(basket
                                                        //           .bsktScripList[index]
                                                        //       ['orderStatus']),
                                                        //   size: 14,
                                                        //   color: _getItemStatusColor(
                                                        //       basket.bsktScripList[
                                                        //               index]
                                                        //           ['orderStatus']),
                                                        // ),
                                                        // const SizedBox(width: 4),
                                                        TextWidget.paraText(
                                                          text: basket
                                                              .bsktScripList[
                                                                  index][
                                                                  'orderStatus']
                                                              .toString()
                                                              .toUpperCase(),
                                                          theme: false,
                                                          fw: 0,
                                                          color: _getItemStatusColor(
                                                              basket.bsktScripList[
                                                                      index][
                                                                  'orderStatus'], theme),
                                                        ),
                                                        if (basket.bsktScripList[
                                                                    index]
                                                                ['avgPrice'] !=
                                                            null) ...[
                                                          const SizedBox(
                                                              width: 8),
                                                          TextWidget
                                                              .captionText(
                                                            text:
                                                                "@ ₹${basket.bsktScripList[index]['avgPrice']}",
                                                            theme: false,
                                                            color: theme
                                                                    .isDarkMode
                                                                ? colors
                                                                    .textSecondaryDark
                                                                : colors
                                                                    .textSecondaryLight,
                                                            fw: 0,
                                                          ),
                                                        ],
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ]),
                                          const SizedBox(height: 8),
                                          Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    Row(
                                                      children: [
                                                        TextWidget.paraText(
                                                          text:
                                                              "${basket.bsktScripList[index]["exch"]} - ${basket.bsktScripList[index]["ordType"]} - ${basket.bsktScripList[index]["prctype"]} - ${formatToTimeOnly(basket.bsktScripList[index]["date"])}",
                                                          theme: false,
                                                          color: theme
                                                                  .isDarkMode
                                                              ? colors
                                                                  .textSecondaryDark
                                                              : colors
                                                                  .textSecondaryLight,
                                                          fw: 0,
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    TextWidget.paraText(
                                                      text:
                                                          "LTP ${basket.bsktScripList[index]['lp']?.toString() ?? "0.00"}",
                                                      theme: false,
                                                      color: theme.isDarkMode
                                                          ? colors
                                                              .textSecondaryDark
                                                          : colors
                                                              .textSecondaryLight,
                                                          fw: 0,
                                                    ),
                                                  ],
                                                ),
                                              ]),
                                          const SizedBox(height: 8),
              
                                          // TextWidget.paraText(
                                          //           text:
                                          //               " (${basket.bsktScripList[index]['pc']?.toString() ?? "0.00"}%)",
                                          //           theme: false,
                                          //           color: basket.bsktScripList[
                                          //                           index]['pc']
                                          //                       ?.toString()
                                          //                       .startsWith(
                                          //                           "-") ??
                                          //                   false
                                          //               ? colors.darkred
                                          //               : basket.bsktScripList[
                                          //                               index]
                                          //                               ['pc']
                                          //                           ?.toString() ==
                                          //                       "0.00"
                                          //                   ? colors.ltpgrey
                                          //                   : colors.ltpgreen,
                                          //           fw: 0),
              
                                          Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Row(children: [
                                                  TextWidget.paraText(
                                                      text: basket.bsktScripList[
                                                                      index][
                                                                  "trantype"] ==
                                                              "S"
                                                          ? "SELL"
                                                          : "BUY",
                                                      theme: false,
                                                      color: basket.bsktScripList[
                                                                      index][
                                                                  "trantype"] ==
                                                              "S"
                                                          ? theme.isDarkMode
                                                              ? colors.lossDark
                                                              : colors.lossLight
                                                          : theme.isDarkMode
                                                              ? colors
                                                                  .primaryDark
                                                              : colors
                                                                  .primaryLight,
                                                      fw: 0),
                                                  const SizedBox(width: 8),
                                                  TextWidget.paraText(
                                                    text:
                                                        "${basket.bsktScripList[index]["dscqty"]}/${basket.bsktScripList[index]["qty"]}",
                                                    theme: theme.isDarkMode,
                                                    color: theme.isDarkMode
                                                        ? colors
                                                            .textSecondaryDark
                                                        : colors
                                                            .textSecondaryLight,
                                                      fw: 0,
                                                  )
                                                ]),
                                                Row(children: [
                                                  if (basket.bsktScripList[
                                                          index]["prctype"] !=
                                                      "MKT") ...[
                                                    TextWidget.paraText(
                                                      text:
                                                          "${basket.bsktScripList[index]['prc'] ?? 0.00}",
                                                      theme: false,
                                                      color: theme.isDarkMode
                                                          ? colors
                                                              .textSecondaryDark
                                                          : colors
                                                              .textSecondaryLight,
                                                      fw: 0,
                                                    ),
                                                  ]
                                                ])
                                              ]),
                                          // Individual Order Status Display
                                        ])),
                              );
                            },
                          );
                        },
                      )),
          ]),
        ),
        bottomNavigationBar: basket.bsktScripList.isEmpty
            ? null
            : SafeArea(
              child: Padding(
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Static error message for multiple exchanges
                      if (basket.bsktScripList.isNotEmpty &&
                          _hasMultipleExchanges(basket.bsktScripList))
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 12),
                          decoration: BoxDecoration(
                            color: colors.loss,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextWidget.paraText(
                                text:
                                    "Basket should contain orders of only 1 segment",
                                theme: false,
                                color: colors.colorWhite,
                                fw: 0,
                              ),
                            ],
                          ),
                        ),
                      Container(
                        height: 75,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.isDarkMode
                              ? colors.colorBlack
                              : colors.colorWhite,
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          height: 45,
                          child: _hasOrdersPlacedInBasket(bsktName, basket)
                              ? OutlinedButton.icon(
                                  onPressed: () {
                                    basket.resetBasketOrderTracking(bsktName);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: TextWidget.paraText(
                                            text: "Basket reset. You can place orders again.",
                                            theme: false,
                                            color: colors.colorWhite,
                                            fw: 0,
                                            ),
                                        backgroundColor: colors.ltpgreen,
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                  },
                                  label: TextWidget.subText(
                                    text: "Reset Orders",
                                    theme: false,
                                      color: theme.isDarkMode
                                                                  ? colors
                                                                      .colorWhite
                                                                  : colors
                                                                      .primaryLight,
                                    fw: 2,
                                  ),
                                  style: OutlinedButton.styleFrom(
                                      minimumSize: const Size(0, 45),
                                      side: BorderSide(
                                        color: theme.isDarkMode
                                            ? colors.colorGrey
                                            : colors.primaryLight,
                                      ),
                                       backgroundColor:theme.isDarkMode
                                                            ? colors
                                                                .textSecondaryDark
                                                                .withOpacity(0.6)
                                                            : colors.btnBg,
                                      shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(5)))),
                                )
                              : OutlinedButton.icon(
                                  onPressed:
                                      _hasMultipleExchanges(basket.bsktScripList)
                                          ? () {}
                                          : () async {
                                              await basket.placeBasketOrder(
                                                  context,
                                                  navigateToOrderBook: false);
                                            },
                                  label: TextWidget.subText(
                                    text: "Place Order",
                                    theme: false,
                                    color: _hasMultipleExchanges(
                                            basket.bsktScripList)
                                            ? colors.colorWhite.withOpacity(0.3) : colors.colorWhite,
                                    fw: 2,
                                  ),
                                  style: OutlinedButton.styleFrom(
                                      side: BorderSide.none,
                                    minimumSize: const Size(0, 45),
                                    backgroundColor: _hasMultipleExchanges(
                                            basket.bsktScripList)
                                        ? (theme.isDarkMode
                                            ? colors.textSecondaryDark.withOpacity(0.3)
                                            : colors.textSecondaryLight.withOpacity(0.3))
                                        : (theme.isDarkMode
                                            ? colors.primaryDark
                                            : colors.primaryLight),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
              ),
            ));
  }

  String formatToTimeOnly(String rawDate) {
    try {
      final dateTime = DateFormat("dd MMM yyyy, hh:mm a").parse(rawDate);
      return DateFormat("hh:mm a").format(dateTime);
    } catch (e) {
      return ''; // or return rawDate if you want fallback
    }
  }

  // Helper methods for individual item status indicators
  Color _getItemStatusColor(String status, theme) {
    switch (status.toLowerCase()) {
      case 'placed':
        return  theme.isDarkMode ? colors.primaryDark : colors.primaryLight;
      case 'complete':
        return  theme.isDarkMode ? colors.profitDark : colors.profitLight;
      case 'rejected':
      case 'canceled':
      case 'failed':
        return  theme.isDarkMode ? colors.lossDark : colors.lossLight;
      case 'open':
      case 'partial':
      case 'trigger_pending':
        return  theme.isDarkMode ? colors.pending : colors.pending;
      default:
        return  theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight;
    }
  }

  IconData _getItemStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'placed':
        return Icons.send;
      case 'complete':
        return Icons.check_circle;
      case 'rejected':
      case 'canceled':
      case 'failed':
        return Icons.cancel;
      case 'open':
      case 'partial':
      case 'trigger_pending':
        return Icons.schedule;
      default:
        return Icons.info_outline;
    }
  }
}
