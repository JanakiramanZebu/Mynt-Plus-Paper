import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

import '../../../models/order_book_model/order_book_model.dart';
import '../../../provider/market_watch_provider.dart';
import '../../../provider/order_provider.dart';
import '../../../provider/thems.dart';
import '../../../provider/websocket_provider.dart';
import '../../../res/global_state_text.dart';
import '../../../res/res.dart';
import '../../../routes/route_names.dart';
import '../../../sharedWidget/custom_back_btn.dart';
import '../../../sharedWidget/custom_exch_badge.dart';
import '../../../sharedWidget/functions.dart';
import '../../../sharedWidget/list_divider.dart';
import '../../../sharedWidget/no_data_found.dart';

class BasketList extends ConsumerWidget {
  const BasketList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final basket = ref.watch(orderProvider);
    final theme = ref.watch(themeProvider);
    bool _isDeleting = false;

    return basket.bsktList.isEmpty
        ? const NoDataFound()
        : ListView.separated(
            shrinkWrap: true,
            itemCount: basket.bsktList.length,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                  onLongPress: () {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) {
                        return StatefulBuilder(
                          builder: (BuildContext context,
                              StateSetter setDialogState) {
                            return AlertDialog(
                              backgroundColor: theme.isDarkMode
                                  ? const Color.fromARGB(255, 18, 18, 18)
                                  : colors.colorWhite,
                              shape: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(16))),
                              scrollable: true,
                              actionsPadding: const EdgeInsets.only(
                                  left: 16, right: 16, bottom: 14, top: 10),
                              contentPadding: EdgeInsets.zero,
                              insetPadding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              titlePadding: const EdgeInsets.only(
                                  left: 16, right: 8, top: 0, bottom: 0),
                              title: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    TextWidget.titleText(
                                        text: "Delete Basket",
                                        theme: theme.isDarkMode,
                                        fw: 1),
                                    InkWell(
                                      onTap: () {
                                        Navigator.pop(context);
                                      },
                                      borderRadius: BorderRadius.circular(
                                          32), // Makes the ripple circular
                                      splashColor: theme.isDarkMode
                                          ? Colors.white.withOpacity(0.2)
                                          : Colors.black.withOpacity(0.1),
                                      highlightColor: Colors
                                          .transparent, // Optional: remove highlight if not needed
                                      customBorder:
                                          const CircleBorder(), // Ensures ripple is circular
                                      child: Padding(
                                        padding: const EdgeInsets.all(
                                            8.0), // Ensures enough space for ripple
                                        child: Icon(
                                          Icons.close_rounded,
                                          size: 22,
                                          color: theme.isDarkMode
                                              ? const Color(0xffBDBDBD)
                                              : colors.colorGrey,
                                        ),
                                      ),
                                    )
                                  ]),
                              content: SizedBox(
                                  width: MediaQuery.of(context).size.width,
                                  child: Column(children: [
                                    const ListDivider(),
                                    const SizedBox(height: 14),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16),
                                      child: TextWidget.subText(
                                          text:
                                              "Are you sure you want to delete this basket ${basket.bsktList[index]['bsketName'].toString().toUpperCase()} ?",
                                          theme: theme.isDarkMode,
                                          fw: 0),
                                    ),
                                  ])),
                              actions: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: (_isDeleting)
                                            ? null
                                            : () async {
                                                setDialogState(() {
                                                  _isDeleting = true;
                                                });
                                                await basket
                                                    .removeBasket(index);
                                                Navigator.pop(context);

                                                if (context.mounted) {
                                                  setDialogState(() {
                                                    _isDeleting = false;
                                                  });
                                                }
                                              },
                                        style: OutlinedButton.styleFrom(
                                          minimumSize: const Size(
                                              0, 40), // width, height
                                          side: BorderSide(
                                              color: colors
                                                  .darkred), // Outline border color
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                          backgroundColor: Colors
                                              .transparent, // Transparent background
                                        ),
                                        child: (_isDeleting)
                                            ? const SizedBox(
                                                width: 18,
                                                height: 20,
                                                child:
                                                    CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        color:
                                                            Color(0xff666666)),
                                              )
                                            : TextWidget.subText(
                                                text: "Delete",
                                                color: colors.kColorRedText,
                                                theme: theme.isDarkMode,
                                                fw: 0),
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
                  onTap: () async {
                    await basket.fetchBasketMargin();
                    basket.chngBsktName(
                        basket.bsktList[index]['bsketName'], context);
                  },
                  dense: true,
                  trailing: TextWidget.paraText(
                      text:
                          "${basket.bsktList[index]['curLength']} / ${basket.bsktList[index]['max']}",
                      theme: false,
                      color: theme.isDarkMode
                          ? colors.textSecondaryDark
                          : colors.textSecondaryLight,
                      fw: 3),
                  title: TextWidget.subText(
                      text:
                          "Basket name: ${basket.bsktList[index]['bsketName']}",
                      theme: false,
                      color: theme.isDarkMode
                          ? colors.textSecondaryDark
                          : colors.textSecondaryLight,
                      fw: 3),
                  subtitle: TextWidget.paraText(
                      text:
                          "Created on: ${basket.bsktList[index]['createdDate']}",
                      theme: false,
                      color: theme.isDarkMode
                          ? colors.textSecondaryDark
                          : colors.textSecondaryLight,
                      fw: 3));
            },
            separatorBuilder: (BuildContext context, int index) {
              return const ListDivider();
            },
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
            shadowColor: const Color(0xffECEFF3),
            title: TextWidget.subText(
                text: "${bsktName}   (${basket.bsktScripList.length} / ${20})",
                theme: false,
                color: theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                fw: 1),
            actions: basket.bsktScripList.length < 20
                ? [
                    Row(
                      children: [
                        Container(
                            margin: const EdgeInsets.only(right: 8),
                            height: 30,
                            child: OutlinedButton(
                                onPressed: () async {
                                  // Check if basket already has 20 items
                                  if (basket.bsktScripList.length >= 20) {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                      content: Text(
                                          "Basket limit reached. Please create a new basket as you are exceeding the 20 item limit."),
                                      backgroundColor: colors.darkred,
                                      duration: Duration(seconds: 3),
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
                                style: OutlinedButton.styleFrom(
                                    side: BorderSide(
                                        color: theme.isDarkMode
                                            ? colors.colorGrey
                                            : colors.colorBlack),
                                    shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(32)))),
                                child: TextWidget.paraText(
                                    text: "Add symbol",
                                    theme: false,
                                    color: theme.isDarkMode
                                        ? colors.colorWhite
                                        : colors.colorBlack,
                                    fw: 1))),
                      ],
                    ),
                  ]
                : null),
        body: Column(children: [
          Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: theme.isDarkMode
                      ? const Color(0xffB5C0CF).withOpacity(.15)
                      : const Color(0xffF1F3F8)),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextWidget.paraText(
                                  text: "Pre Trade Margin",
                                  theme: false,
                                  color: const Color(0xff5E6B7D),
                                  fw: 0),
                              const SizedBox(height: 6),
                              TextWidget.subText(
                                  text: basket.bsktScripList.isEmpty ||
                                          basket.bsktOrderMargin == null
                                      ? "₹0.00"
                                      : "₹${basket.bsktOrderMargin!.marginusedtrade ?? 0.00}",
                                  theme: theme.isDarkMode,
                                  fw: 0),
                            ],
                          ),
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                TextWidget.paraText(
                                    text: "Post Trade Margin",
                                    theme: false,
                                    color: const Color(0xff5E6B7D),
                                    fw: 0),
                                const SizedBox(height: 6),
                                TextWidget.titleText(
                                    text: basket.bsktScripList.isEmpty ||
                                            basket.bsktOrderMargin == null
                                        ? "₹0.00"
                                        : "₹${basket.bsktOrderMargin!.marginused ?? 0.00}",
                                    theme: theme.isDarkMode,
                                    fw: 0),
                              ])
                        ]),
                  ])),
          if (basket.bsktScripList.isNotEmpty &&
              _hasMultipleExchanges(basket.bsktScripList))
            Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.symmetric(vertical: 3),
              decoration: BoxDecoration(
                  color: const Color(0xffe3f2fd),
                  borderRadius: BorderRadius.circular(6)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: colors.darkred, size: 16),
                  const SizedBox(width: 8),
                  TextWidget.subText(
                      text: "Basket should contain orders of only 1 exchange",
                      theme: false,
                      color: colors.darkred,
                      fw: 0),
                ],
              ),
            ),
          Container(
              padding: const EdgeInsets.symmetric(vertical: 3),
              decoration: BoxDecoration(
                  color: const Color(0xffe3f2fd),
                  borderRadius: BorderRadius.circular(6)),
              child:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                SvgPicture.asset(assets.dInfo, color: colors.colorBlue),
                TextWidget.paraText(
                    text: " On Script Tap to edit / long press to delete.",
                    theme: false,
                    color: colors.colorBlue,
                    fw: 0),
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
                          itemBuilder: (BuildContext context, int index) {
                            if (basket.bsktScripList[index]['exch'] == "BFO" &&
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
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                          backgroundColor: theme.isDarkMode
                                              ? const Color.fromARGB(
                                                  255, 18, 18, 18)
                                              : colors.colorWhite,
                                          shape: const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(10))),
                                          scrollable: true,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 16),
                                          insetPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 24),
                                          titlePadding: const EdgeInsets.all(0),
                                          title: Padding(
                                            padding: const EdgeInsets.all(10),
                                            child: SvgPicture.asset(
                                                "assets/icon/ipo_cancel_icon.svg"),
                                          ),
                                          content: Column(
                                            children: [
                                              TextWidget.titleText(
                                                  text:
                                                      "Are you sure you want to delete this basket Scrip ${basket.bsktScripList[index]['symbol']}",
                                                  theme: theme.isDarkMode,
                                                  fw: 1,
                                                  align: TextAlign.center),
                                            ],
                                          ),
                                          actions: [
                                            Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Expanded(
                                                    child: ElevatedButton(
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                                elevation: 0,
                                                                backgroundColor:
                                                                    const Color(
                                                                        0xffF1F3F8),
                                                                shape:
                                                                    RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              50),
                                                                )),
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        child:
                                                            TextWidget.paraText(
                                                                text: "No",
                                                                theme: false,
                                                                color: colors
                                                                    .colorGrey,
                                                                fw: 1)),
                                                  ),
                                                  const SizedBox(width: 16),
                                                  Expanded(
                                                      child: ElevatedButton(
                                                          style: ElevatedButton
                                                              .styleFrom(
                                                                  elevation: 0,
                                                                  backgroundColor: theme
                                                                          .isDarkMode
                                                                      ? colors
                                                                          .colorbluegrey
                                                                      : colors
                                                                          .colorBlack,
                                                                  shape:
                                                                      RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            50),
                                                                  )),
                                                          onPressed: () async {
                                                            await basket
                                                                .removeBsktScrip(
                                                                    index,
                                                                    bsktName);
                                                            await basket
                                                                .fetchBasketMargin();
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          child: TextWidget
                                                              .paraText(
                                                                  text: "Yes",
                                                                  theme: theme
                                                                      .isDarkMode,
                                                                  fw: 1)))
                                                ])
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
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(children: [
                                                TextWidget.subText(
                                                    text:
                                                        "${basket.bsktScripList[index]['symbol']}",
                                                    theme: theme.isDarkMode,
                                                    fw: 1,
                                                    textOverflow:
                                                        TextOverflow.ellipsis),
                                                TextWidget.subText(
                                                    text:
                                                        " ${basket.bsktScripList[index]['option']} ",
                                                    theme: theme.isDarkMode,
                                                    fw: 1,
                                                    textOverflow:
                                                        TextOverflow.ellipsis),
                                              ]),
                                              Row(
                                                children: [
                                                  TextWidget.paraText(
                                                      text: " LTP: ",
                                                      theme: false,
                                                      color: const Color(
                                                          0xff5E6B7D),
                                                      fw: 1),
                                                  TextWidget.subText(
                                                      text:
                                                          "₹${basket.bsktScripList[index]['lp']?.toString() ?? "0.00"}",
                                                      theme: theme.isDarkMode,
                                                      fw: 0),
                                                ],
                                              ),
                                            ]),
                                        const SizedBox(height: 4),
                                        Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  CustomExchBadge(
                                                      exch:
                                                          "${basket.bsktScripList[index]["exch"]}"),
                                                  TextWidget.captionText(
                                                      text:
                                                          " ${basket.bsktScripList[index]['expDate']} ",
                                                      theme: theme.isDarkMode,
                                                      fw: 0,
                                                      textOverflow: TextOverflow
                                                          .ellipsis),
                                                ],
                                              ),
                                              TextWidget.paraText(
                                                  text:
                                                      " (${basket.bsktScripList[index]['pc']?.toString() ?? "0.00"}%)",
                                                  theme: false,
                                                  color: basket.bsktScripList[
                                                                  index]['pc']
                                                              ?.toString()
                                                              .startsWith(
                                                                  "-") ??
                                                          false
                                                      ? colors.darkred
                                                      : basket.bsktScripList[
                                                                      index]
                                                                      ['pc']
                                                                  ?.toString() ==
                                                              "0.00"
                                                          ? colors.ltpgrey
                                                          : colors.ltpgreen,
                                                  fw: 0),
                                            ]),
                                        const SizedBox(height: 4),
                                        Divider(
                                            color: theme.isDarkMode
                                                ? colors.darkColorDivider
                                                : colors.colorDivider),
                                        const SizedBox(height: 2),
                                        Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(children: [
                                                Container(
                                                    padding: const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 2),
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                4),
                                                        color: theme.isDarkMode
                                                            ? basket.bsktScripList[index]["trantype"] ==
                                                                    "S"
                                                                ? colors.darkred
                                                                    .withOpacity(
                                                                        .2)
                                                                : colors.ltpgreen
                                                                    .withOpacity(
                                                                        .2)
                                                            : Color(basket.bsktScripList[index]["trantype"] == "S"
                                                                ? 0xffFCF3F3
                                                                : 0xffECF8F1)),
                                                    child: TextWidget.paraText(
                                                        text: basket.bsktScripList[index]["trantype"] == "S"
                                                            ? "SELL"
                                                            : "BUY",
                                                        theme: false,
                                                        color: basket.bsktScripList[index]
                                                                    ["trantype"] ==
                                                                "S"
                                                            ? colors.darkred
                                                            : colors.ltpgreen,
                                                        fw: 1)),
                                                Container(
                                                    margin: const EdgeInsets.only(
                                                        left: 7),
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                            horizontal: 7,
                                                            vertical: 2),
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                4),
                                                        color: theme.isDarkMode
                                                            ? const Color(0xff666666)
                                                                .withOpacity(.2)
                                                            : const Color(
                                                                    0xff999999)
                                                                .withOpacity(
                                                                    .2)),
                                                    child: TextWidget.paraText(
                                                        text:
                                                            "${basket.bsktScripList[index]["prctype"]}",
                                                        theme: false,
                                                        color: const Color(
                                                            0xff666666),
                                                        fw: 1)),
                                                Container(
                                                    margin: const EdgeInsets.only(
                                                        left: 7),
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                            horizontal: 7,
                                                            vertical: 2),
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                4),
                                                        color: theme.isDarkMode
                                                            ? const Color(0xff666666)
                                                                .withOpacity(.2)
                                                            : const Color(
                                                                    0xff999999)
                                                                .withOpacity(
                                                                    .2)),
                                                    child: TextWidget.paraText(
                                                        text:
                                                            "${basket.bsktScripList[index]["ordType"]}",
                                                        theme: false,
                                                        color: const Color(
                                                            0xff666666),
                                                        fw: 1))
                                              ]),
                                              Row(children: [
                                                TextWidget.paraText(
                                                    text: "Qty: ",
                                                    theme: false,
                                                    color:
                                                        const Color(0xff5E6B7D),
                                                    fw: 1),
                                                TextWidget.subText(
                                                    text:
                                                        "${basket.bsktScripList[index]["dscqty"]}/${basket.bsktScripList[index]["qty"]}",
                                                    theme: theme.isDarkMode,
                                                    fw: 0),
                                              ])
                                            ]),
                                        const SizedBox(height: 10),
                                        Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(children: [
                                                TextWidget.paraText(
                                                    text:
                                                        "${basket.bsktScripList[index]["date"]}",
                                                    theme: false,
                                                    color:
                                                        const Color(0xff666666),
                                                    fw: 0),
                                              ]),
                                              Row(children: [
                                                if (basket.bsktScripList[index]
                                                        ["prctype"] !=
                                                    "MKT") ...[
                                                  TextWidget.subText(
                                                      text: "Price: ",
                                                      theme: false,
                                                      color: const Color(
                                                          0xff5E6B7D),
                                                      fw: 0),
                                                  TextWidget.subText(
                                                      text:
                                                          "${basket.bsktScripList[index]['prc'] ?? 0.00}",
                                                      theme: false,
                                                      color: theme.isDarkMode
                                                          ? colors.colorWhite
                                                          : colors.colorBlack,
                                                      fw: 0),
                                                ]
                                              ])
                                            ])
                                      ])),
                            );
                          },
                          separatorBuilder: (BuildContext context, int index) {
                            return Container(
                                color: theme.isDarkMode
                                    ? colors.darkGrey
                                    : const Color(0xffF1F3F8),
                                height: 6);
                          },
                        );
                      },
                    )),
        ]),
        bottomNavigationBar: basket.bsktScripList.isEmpty
            ? null
            : BottomAppBar(
                shape: const CircularNotchedRectangle(),
                child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    height: 40,
                    decoration: BoxDecoration(
                        border: Border.all(
                            color: _hasMultipleExchanges(basket.bsktScripList)
                                ? Colors.grey
                                : (theme.isDarkMode
                                    ? colors.colorWhite
                                    : colors.colorBlack)),
                        borderRadius: BorderRadius.circular(108)),
                    child: InkWell(
                        onTap: _hasMultipleExchanges(basket.bsktScripList)
                            ? () {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  content: Text(
                                      "Cannot place order: Basket should contain orders from only 1 exchange"),
                                  backgroundColor: colors.darkred,
                                  duration: Duration(seconds: 3),
                                ));
                              }
                            : () async {
                                basket.placeBasketOrder(context);
                              },
                        child: Center(
                          child: TextWidget.subText(
                              text: "Place Order",
                              theme: false,
                              color: _hasMultipleExchanges(basket.bsktScripList)
                                  ? Colors.grey
                                  : (theme.isDarkMode
                                      ? colors.colorWhite
                                      : colors.colorBlack),
                              fw: 1),
                        )))));
  }
}
