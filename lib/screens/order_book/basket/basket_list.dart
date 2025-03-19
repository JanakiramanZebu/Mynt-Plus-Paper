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
  Widget build(BuildContext context, ScopedReader watch) {
    final basket = watch(orderProvider);
    final theme = watch(themeProvider);
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
                                                    const Color(0xffF1F3F8),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(50),
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
                                              style: ElevatedButton.styleFrom(
                                                  elevation: 0,
                                                  backgroundColor:
                                                      theme.isDarkMode
                                                          ? colors.colorbluegrey
                                                          : colors.colorBlack,
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
                                                      theme.isDarkMode
                                                          ? colors.colorBlack
                                                          : colors.colorWhite,
                                                      12,
                                                      FontWeight.w600))))
                                    ])
                              ]);
                        });
                  },
                  onTap: () {
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

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final theme = context.read(themeProvider);
    final basket = watch(orderProvider);
    final socketDatas = watch(websocketProvider).socketDatas;
    return Scaffold(
        appBar: AppBar(
            elevation: .2,
            leadingWidth: 41,
            centerTitle: false,
            titleSpacing: 6,
            leading: const CustomBackBtn(),
            shadowColor: const Color(0xffECEFF3),
            title: Text(bsktName,
                style: textStyle(
                    theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                    14,
                    FontWeight.w600)),
            actions: basket.bsktScripList.length <= 20
                ? [
                    Row(
                      children: [
                        Container(
                            margin: const EdgeInsets.only(right: 8),
                            height: 30,
                            child: OutlinedButton(
                                onPressed: () async {
                                  await watch(marketWatchProvider)
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
                        ])
                  ])),
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
                  : ListView.separated(
                      shrinkWrap: true,
                      itemCount: basket.bsktScripList.length,
                      itemBuilder: (BuildContext context, int index) {
                        if (socketDatas.containsKey(
                            basket.bsktScripList[index]['token'])) {
                          basket.bsktScripList[index]['lp'] =
                              "${socketDatas["${basket.bsktScripList[index]['token']}"]['lp']}";
                          basket.bsktScripList[index]['pc'] =
                              "${socketDatas["${basket.bsktScripList[index]['token']}"]['pc']}";
                        }

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
                            await context
                                .read(marketWatchProvider)
                                .fetchScripInfo(
                                    "${basket.bsktScripList[index]['token']}",
                                    '${basket.bsktScripList[index]['exch']}',
                                    context);
                            basket.bsktScripList[index]['index'] = index;
                            basket.bsktScripList[index]['prctyp'] =
                                basket.bsktScripList[index]['prctype'];
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
                                lotSize: context
                                    .read(marketWatchProvider)
                                    .scripInfoModel
                                    ?.ls
                                    .toString(),
                                ltp: basket.bsktScripList[index]['lp'],
                                perChange: basket.bsktScripList[index]['pc'],
                                orderTpye: '',
                                holdQty: '',
                                isModify: true,
                                raw: basket.bsktScripList[index]);
                            Navigator.pushNamed(
                                context, Routes.placeOrderScreen,
                                arguments: {
                                  "orderArg": orderArgs,
                                  "scripInfo": context
                                      .read(marketWatchProvider)
                                      .scripInfoModel!,
                                  "isBskt": 'BasketEdit'
                                });
                            // await basket.removeBsktScrip(index, bsktName);
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
                                                  "₹${basket.bsktScripList[index]['lp'] ?? 0.00}",
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
                                              " (${basket.bsktScripList[index]['pc'] ?? 0.00}%)",
                                              style: textStyle(
                                                  basket.bsktScripList[index]
                                                              ['pc']
                                                          .toString()
                                                          .startsWith("-")
                                                      ? colors.darkred
                                                      : basket.bsktScripList[
                                                                      index]
                                                                      ['pc']
                                                                  .toString() ==
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
                      }))
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
                            color: theme.isDarkMode
                                ? colors.colorWhite
                                : colors.colorBlack),
                        borderRadius: BorderRadius.circular(108)),
                    child: InkWell(
                        onTap: () async {
                          basket.placeBasketOrder(context);
                        },
                        child: Center(
                            child: Text("Place Order",
                                style: textStyle(
                                    theme.isDarkMode
                                        ? colors.colorWhite
                                        : colors.colorBlack,
                                    14,
                                    FontWeight.w600)))))));
  }
}
