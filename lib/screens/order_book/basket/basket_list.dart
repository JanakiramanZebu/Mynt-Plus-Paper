import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

import '../../../models/order_book_model/order_book_model.dart';
import '../../../provider/market_watch_provider.dart';
import '../../../provider/order_provider.dart';
import '../../../provider/thems.dart';
import '../../../provider/websocket_provider.dart';
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
                        builder: (BuildContext context) {
                          return AlertDialog(
                              backgroundColor: theme.isDarkMode
                                  ? const Color.fromARGB(255, 18, 18, 18)
                                  : colors.colorWhite,
                              shape: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              scrollable: true,
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              insetPadding:
                                  const EdgeInsets.symmetric(horizontal: 24),
                              titlePadding: const EdgeInsets.all(0),
                              title: Padding(
                                padding: const EdgeInsets.all(10),
                                child: SvgPicture.asset(
                                    "assets/icon/ipo_cancel_icon.svg"),
                              ),
                              content: Column(
                                children: [
                                  Text(
                                      "Are you sure you want to delete this basket ${basket.bsktList[index]['bsketName'].toString().toUpperCase()}",
                                      textAlign: TextAlign.center,
                                      style: textStyle(
                                          theme.isDarkMode
                                              ? colors.colorWhite
                                              : colors.colorBlack,
                                          16,
                                          FontWeight.w600))
                                ],
                              ),
                              actions: [
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                                elevation: 0,
                                                backgroundColor:
                                                    theme.isDarkMode
                                                          ? colors.colorbluegrey
                                                          : colors.colorBlack,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(50),
                                                )),
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: Text("No",
                                                style: textStyle(
                                                  theme.isDarkMode
                                                          ? colors.colorBlack
                                                          : colors.colorWhite,
                                                    12,
                                                    FontWeight.w600))),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                          child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                  elevation: 0,
                                                  backgroundColor:
                                                          const Color(0xffF1F3F8),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            50),
                                                  )),
                                              onPressed: () async {
                                                await basket
                                                    .removeBasket(index);
                                                Navigator.pop(context);
                                              },
                                              child: Text("Yes",
                                                  style: textStyle(
                                                      colors.colorGrey,
                                                      12,
                                                      FontWeight.w600))))
                                    ])
                              ]);
                        });
                  },
                  onTap: () async {
                    await basket
                                                                .fetchBasketMargin();
                    basket.chngBsktName(
                        basket.bsktList[index]['bsketName'], context);
                  },
                  dense: true,
                  trailing: Text(
                      "${basket.bsktList[index]['curLength']} / ${basket.bsktList[index]['max']}",
                      style: textStyles.scripExchTxtStyle.copyWith(
                          color: theme.isDarkMode
                              ? colors.colorWhite
                              : colors.colorBlack)),
                  title: Text(
                      "Basket name: ${basket.bsktList[index]['bsketName']}",
                      style: textStyles.scripNameTxtStyle.copyWith(
                          color: theme.isDarkMode
                              ? colors.colorWhite
                              : colors.colorBlack)),
                  subtitle: Text(
                      "Created on: ${basket.bsktList[index]['createdDate']}",
                      style: textStyles.scripExchTxtStyle.copyWith(
                          color: theme.isDarkMode
                              ? colors.colorWhite
                              : colors.colorBlack)));
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
            title: Text("${bsktName}   (${basket.bsktScripList.length} / ${20})",
                style: textStyle(
                    theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                    14,
                    FontWeight.w600)),
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
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("Basket limit reached. Please create a new basket as you are exceeding the 20 item limit."),
                                        backgroundColor: colors.darkred,
                                        duration: Duration(seconds: 3),
                                      )
                                    );
                                    return;
                                  }
                                  
                                  await ref.watch(marketWatchProvider)
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
                                child: Text("Add symbol",
                                    style: textStyle(
                                        theme.isDarkMode
                                            ? colors.colorWhite
                                            : colors.colorBlack,
                                        12,
                                        FontWeight.w600)))),
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
                              Text("Pre Trade Margin",
                                  style: textStyle(const Color(0xff5E6B7D), 12,
                                      FontWeight.w500)),
                              const SizedBox(height: 6),
                              Text(
                                  basket.bsktScripList.isEmpty ||
                                          basket.bsktOrderMargin == null
                                      ? "₹0.00"
                                      : "₹${basket.bsktOrderMargin!.marginusedtrade ?? 0.00}",
                                  style: textStyle(
                                      theme.isDarkMode
                                          ? colors.colorWhite
                                          : colors.colorBlack,
                                      14,
                                      FontWeight.w500)),
                            ],
                          ),
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text("Post Trade Margin",
                                    style: textStyle(const Color(0xff5E6B7D),
                                        12, FontWeight.w500)),
                                const SizedBox(height: 6),
                                Text(
                                    basket.bsktScripList.isEmpty ||
                                            basket.bsktOrderMargin == null
                                        ? "₹0.00"
                                        : "₹${basket.bsktOrderMargin!.marginused ?? 0.00}",
                                    style: textStyle(
                                        theme.isDarkMode
                                            ? colors.colorWhite
                                            : colors.colorBlack,
                                        16,
                                        FontWeight.w500)),
                              ])
                        ]),
                    
                  ])),
                  if (basket.bsktScripList.isNotEmpty && _hasMultipleExchanges(basket.bsktScripList))
                      Container(
                        margin: const EdgeInsets.only(top: 12),
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xffe3f2fd),
                          borderRadius: BorderRadius.circular(6)
                        ),
                        child: Row(
                           mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline, color: colors.darkred, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              "Basket should contain orders of only 1 exchange",
                              style: textStyle(colors.darkred, 13, FontWeight.w500),
                            ),
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
                Text(" On Script Tap to edit / long press to delete.",
                    style: textStyle(colors.colorBlue, 12, FontWeight.w500))
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
                            if (token != null && socketDatas.containsKey(token)) {
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
                                basket.bsktScripList[index]["dname"] != "null") {
                              List<String> splitVal = basket.bsktScripList[index]
                                      ["dname"]
                                  .toString()
                                  .split(" ");

                              basket.bsktScripList[index]['symbol'] = splitVal[0];
                              basket.bsktScripList[index]['expDate'] =
                                  "${splitVal[1]} ${splitVal[2]}";
                              basket.bsktScripList[index]['option'] =
                                  splitVal.length > 4
                                      ? "${splitVal[3]} ${splitVal[4]}"
                                      : splitVal[3];
                            } else {
                              Map spilitSymbol = spilitTsym(
                                  value: "${basket.bsktScripList[index]['tsym']}");

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
                                          insetPadding: const EdgeInsets.symmetric(
                                              horizontal: 24),
                                          titlePadding: const EdgeInsets.all(0),
                                          title: Padding(
                                            padding: const EdgeInsets.all(10),
                                            child: SvgPicture.asset(
                                                "assets/icon/ipo_cancel_icon.svg"),
                                          ),
                                          content: Column(
                                            children: [
                                              Text(
                                                  "Are you sure you want to delete this basket Scrip ${basket.bsktScripList[index]['symbol']}",
                                                  textAlign: TextAlign.center,
                                                  style: textStyle(
                                                      theme.isDarkMode
                                                          ? colors.colorWhite
                                                          : colors.colorBlack,
                                                      16,
                                                      FontWeight.w600))
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
                                                          Navigator.pop(context);
                                                        },
                                                        child: Text("No",
                                                            style: textStyle(
                                                                colors.colorGrey,
                                                                12,
                                                                FontWeight.w600))),
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
                                                                        BorderRadius
                                                                            .circular(
                                                                                50),
                                                                  )),
                                                          onPressed: () async {
                                                            await basket
                                                                .removeBsktScrip(
                                                                    index,
                                                                    bsktName);
                                                                   await basket
                                                                .fetchBasketMargin();
                                                            Navigator.pop(context);
                                                          },
                                                          child: Text("Yes",
                                                              style: textStyle(
                                                                  theme.isDarkMode
                                                                      ? colors
                                                                          .colorBlack
                                                                      : colors
                                                                          .colorWhite,
                                                                  12,
                                                                  FontWeight
                                                                      .w600))))
                                                ])
                                          ]);
                                    });
                              },
                              onTap: () async {
                                await ref
                                    .read(marketWatchProvider)
                                    .fetchScripInfo(
                                        "${basket.bsktScripList[index]['token']}",
                                        '${basket.bsktScripList[index]['exch']}',
                                        context, true);
                                basket.bsktScripList[index]['index'] = index;
                                basket.bsktScripList[index]['prctyp'] =
                                    basket.bsktScripList[index]['prctype'];
                                
                                // Ensure lp and pc values are not null for OrderScreenArgs
                                final ltp = basket.bsktScripList[index]['lp']?.toString() ?? "0.00";
                                final perChange = basket.bsktScripList[index]['pc']?.toString() ?? "0.00";
                                
                                OrderScreenArgs orderArgs = OrderScreenArgs(
                                    exchange:
                                        '${basket.bsktScripList[index]['exch']}',
                                    tSym: '${basket.bsktScripList[index]['tsym']}',
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
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(children: [
                                                Text(
                                                    "${basket.bsktScripList[index]['symbol']}",
                                                    overflow: TextOverflow.ellipsis,
                                                    style: textStyles
                                                        .scripNameTxtStyle
                                                        .copyWith(
                                                            color: theme.isDarkMode
                                                                ? colors.colorWhite
                                                                : colors
                                                                    .colorBlack)),
                                                Text(
                                                    " ${basket.bsktScripList[index]['option']} ",
                                                    overflow: TextOverflow.ellipsis,
                                                    style: textStyles
                                                        .scripNameTxtStyle
                                                        .copyWith(
                                                            color: theme.isDarkMode
                                                                ? colors.colorWhite
                                                                : colors
                                                                    .colorBlack)),
                                              ]),
                                              Row(
                                                children: [
                                                  Text(" LTP: ",
                                                      style: textStyle(
                                                          const Color(0xff5E6B7D),
                                                          13,
                                                          FontWeight.w600)),
                                                  Text(
                                                      "₹${basket.bsktScripList[index]['lp']?.toString() ?? "0.00"}",
                                                      style: textStyle(
                                                          theme.isDarkMode
                                                              ? colors.colorWhite
                                                              : colors.colorBlack,
                                                          14,
                                                          FontWeight.w500)),
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
                                                  Text(
                                                      " ${basket.bsktScripList[index]['expDate']} ",
                                                      overflow: TextOverflow
                                                          .ellipsis,
                                                      style: textStyles
                                                          .scripExchTxtStyle
                                                          .copyWith(
                                                              color: theme
                                                                      .isDarkMode
                                                                  ? colors
                                                                      .colorWhite
                                                                  : colors
                                                                      .colorBlack))
                                                ],
                                              ),
                                              Text(
                                                  " (${basket.bsktScripList[index]['pc']?.toString() ?? "0.00"}%)",
                                                  style: textStyle(
                                                      basket.bsktScripList[index]
                                                                  ['pc']
                                                              ?.toString()
                                                              .startsWith("-") ??
                                                          false
                                                          ? colors.darkred
                                                          : basket.bsktScripList[
                                                                          index]
                                                                          ['pc']
                                                                      ?.toString() ==
                                                                  "0.00"
                                                              ? colors.ltpgrey
                                                              : colors.ltpgreen,
                                                      12,
                                                      FontWeight.w500)),
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
                                                        horizontal: 8, vertical: 2),
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                4),
                                                        color: theme.isDarkMode
                                                            ? basket.bsktScripList[index]["trantype"] ==
                                                                    "S"
                                                                ? colors.darkred
                                                                    .withOpacity(.2)
                                                                : colors.ltpgreen
                                                                    .withOpacity(.2)
                                                            : Color(
                                                                basket.bsktScripList[index]["trantype"] == "S"
                                                                    ? 0xffFCF3F3
                                                                    : 0xffECF8F1)),
                                                    child: Text(basket.bsktScripList[index]["trantype"] == "S" ? "SELL" : "BUY",
                                                        style: textStyle(
                                                            basket.bsktScripList[index]
                                                                        ["trantype"] ==
                                                                    "S"
                                                                ? colors.darkred
                                                                : colors.ltpgreen,
                                                            12,
                                                            FontWeight.w600))),
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
                                                                .withOpacity(.2)),
                                                    child: Text(
                                                        "${basket.bsktScripList[index]["prctype"]}",
                                                        style: textStyle(
                                                            const Color(0xff666666),
                                                            11,
                                                            FontWeight.w600))),
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
                                                                .withOpacity(.2)),
                                                    child: Text(
                                                        "${basket.bsktScripList[index]["ordType"]}",
                                                        style: textStyle(
                                                            const Color(0xff666666),
                                                            11,
                                                            FontWeight.w600)))
                                              ]),
                                              Row(children: [
                                                Text("Qty: ",
                                                    style: textStyle(
                                                        const Color(0xff5E6B7D),
                                                        14,
                                                        FontWeight.w500)),
                                                Text(
                                                    "${basket.bsktScripList[index]["dscqty"]}/${basket.bsktScripList[index]["qty"]}",
                                                    style: textStyle(
                                                        theme.isDarkMode
                                                            ? colors.colorWhite
                                                            : colors.colorBlack,
                                                        14,
                                                        FontWeight.w500))
                                              ])
                                            ]),
                                        const SizedBox(height: 10),
                                        Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(children: [
                                                Text(
                                                    "${basket.bsktScripList[index]["date"]}",
                                                    style: textStyle(
                                                        const Color(0xff666666),
                                                        12,
                                                        FontWeight.w500))
                                              ]),
                                              Row(children: [
                                                if(basket.bsktScripList[index]["prctype"] != "MKT")...[
                                                Text("Price: ",
                                                    style: textStyle(
                                                        const Color(0xff5E6B7D),
                                                        14,
                                                        FontWeight.w500)),
                                                Text(
                                                    "${basket.bsktScripList[index]['prc'] ?? 0.00}",
                                                    style: textStyle(
                                                        theme.isDarkMode
                                                            ? colors.colorWhite
                                                            : colors.colorBlack,
                                                        14,
                                                        FontWeight.w500))
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
                    )
                ),
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
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Cannot place order: Basket should contain orders from only 1 exchange"),
                                  backgroundColor: colors.darkred,
                                  duration: Duration(seconds: 3),
                                )
                              );
                            }
                          : () async {
                              basket.placeBasketOrder(context);
                            },
                        child: Center(
                            child: Text("Place Order",
                                style: textStyle(
                                    _hasMultipleExchanges(basket.bsktScripList)
                                      ? Colors.grey
                                      : (theme.isDarkMode
                                        ? colors.colorWhite
                                        : colors.colorBlack),
                                    14,
                                    FontWeight.w600)))))));
  }
}
