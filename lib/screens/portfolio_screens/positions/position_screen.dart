import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:remove_emoji_input_formatter/remove_emoji_input_formatter.dart';
import '../../../models/portfolio_model/position_book_model.dart';
import '../../../provider/market_watch_provider.dart';
import '../../../provider/portfolio_provider.dart';
import '../../../provider/thems.dart';
import '../../../provider/websocket_provider.dart';
import '../../../res/res.dart';
import '../../../routes/route_names.dart';
import '../../../sharedWidget/custom_text_btn.dart';
import '../../../sharedWidget/custom_text_form_field.dart';
import '../../../sharedWidget/functions.dart';
import '../../../sharedWidget/no_data_found.dart';
import 'filter_scrip_bottom_sheet.dart'; 
import 'group/create_group.dart';
import 'group/position_group_symbol.dart';
import 'position_list_card.dart';

class PositionScreen extends ConsumerWidget {
  final List<PositionBookModel> listofPosition;
  const PositionScreen({super.key, required this.listofPosition});

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final positionBook = watch(portfolioProvider);
    final socketDatas = watch(websocketProvider).socketDatas;
    final theme = context.read(themeProvider);
    return positionBook.posloader
        ? const Center(child: CircularProgressIndicator())
        : Column(children: [
            Container(
                color: theme.isDarkMode
                    ? const Color(0xffB5C0CF).withOpacity(.15)
                    : const Color(0xffF1F3F8),
                padding: const EdgeInsets.all(16),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                              onTap: positionBook.isDay
                                  ? null
                                  : () {
                                      positionBook.chngPositionPnl(false);
                                    },
                              child: Container(
                                padding:
                                    EdgeInsets.all(positionBook.isDay ? 0 : 8),
                                decoration: positionBook.isDay
                                    ? null
                                    : BoxDecoration(
                                        borderRadius: BorderRadius.circular(6),
                                        color: !positionBook.isNetPnl
                                            ? const Color.fromARGB(
                                                    255, 5, 107, 241)
                                                .withOpacity(.2)
                                            : Colors.transparent),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        positionBook.isDay
                                            ? "Unrealised MTM"
                                            : "Net MTM",
                                        style: textStyle(
                                            const Color(0xff5E6B7D),
                                            12,
                                            FontWeight.w500)),
                                    const SizedBox(height: 6),
                                    Text(
                                        "₹${positionBook.isDay ? positionBook.totUnRealMtm : positionBook.totMtM}",
                                        style: textStyle(
                                            positionBook.isDay
                                                ? positionBook.totUnRealMtm
                                                        .startsWith("-")
                                                    ? colors.darkred
                                                    : positionBook
                                                                .totUnRealMtm ==
                                                            "0.00"
                                                        ? colors.ltpgrey
                                                        : colors.ltpgreen
                                                : positionBook.totMtM
                                                        .startsWith("-")
                                                    ? colors.darkred
                                                    : positionBook.totMtM ==
                                                            "0.00"
                                                        ? colors.ltpgrey
                                                        : colors.ltpgreen,
                                            16,
                                            FontWeight.w500)),
                                  ],
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: positionBook.isDay
                                  ? null
                                  : () {
                                      positionBook.chngPositionPnl(true);
                                    },
                              child: Container(
                                padding:
                                    EdgeInsets.all(positionBook.isDay ? 0 : 8),
                                decoration: positionBook.isDay
                                    ? null
                                    : BoxDecoration(
                                        borderRadius: BorderRadius.circular(6),
                                        color: positionBook.isNetPnl
                                            ? const Color.fromARGB(
                                                    255, 5, 107, 241)
                                                .withOpacity(.2)
                                            : Colors.transparent),
                                child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                          positionBook.isDay
                                              ? "Booked P&L"
                                              : "Net P&L",
                                          style: textStyle(
                                              const Color(0xff5E6B7D),
                                              12,
                                              FontWeight.w500)),
                                      const SizedBox(height: 6),
                                      Row(children: [
                                        Text(
                                            "₹${positionBook.isDay ? positionBook.totBookedPnL : positionBook.totPnL}",
                                            style: textStyle(
                                                positionBook.isDay
                                                    ? positionBook.totBookedPnL
                                                            .startsWith("-")
                                                        ? colors.darkred
                                                        : positionBook
                                                                    .totBookedPnL ==
                                                                "0.00"
                                                            ? colors.ltpgrey
                                                            : colors.ltpgreen
                                                    : positionBook.totPnL
                                                            .startsWith("-")
                                                        ? colors.darkred
                                                        : positionBook.totPnL ==
                                                                "0.00"
                                                            ? colors.ltpgrey
                                                            : colors.ltpgreen,
                                                16,
                                                FontWeight.w500))
                                      ])
                                    ]),
                              ),
                            )
                          ])
                    ])),
            if (positionBook. postionBookModel!.isNotEmpty)
              Container(
                padding: const EdgeInsets.only(
                    left: 16, right: 4, top: 8, bottom: 8),
                decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                            color: theme.isDarkMode
                                ? colors.darkGrey
                                : const Color(0xffF1F3F8),
                            width: 6))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // temporary hide
                    // Row(
                    //   children: [
                    //     Text("DAY",
                    //         style: textStyle(
                    //             theme.isDarkMode
                    //                 ? colors.colorWhite
                    //                 : colors.colorBlack,
                    //             13,
                    //             FontWeight.w500)),
                    //     const SizedBox(width: 6),
                    //     CustomSwitch(
                    //         onChanged: (bool value) {
                    //           positionBook.chngPositionPnl(true);
                    //           positionBook.positionToggle(value, context);
                    //         },
                    //         value: positionBook.isDay),
                    //     const SizedBox(width: 6),
                    //     Text("NET",
                    //         style: textStyle(
                    //             theme.isDarkMode
                    //                 ? colors.colorWhite
                    //                 : colors.colorBlack,
                    //             13,
                    //             FontWeight.w500)),
                    //   ],
                    // ),
                    if (listofPosition.length > 1 &&
                        positionBook.posSelection == "All position") ...[
                      Row(
                        children: [
                          InkWell(
                              onTap: () async {
                                showModalBottomSheet(
                                    useSafeArea: true,
                                    isScrollControlled: true,
                                    shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(16))),
                                    context: context,
                                    builder: (context) {
                                      return const PositionScripFilterBottomSheet();
                                    });
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: SvgPicture.asset(assets.filterLines,
                                    color: theme.isDarkMode
                                        ? const Color(0xffBDBDBD)
                                        : colors.colorGrey),
                              )),
                          InkWell(
                              onTap: () {
                                positionBook.showPositionSearch(true);
                              },
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(right: 12, left: 10),
                                child: SvgPicture.asset(assets.searchIcon,
                                    width: 19,
                                    color: theme.isDarkMode
                                        ? const Color(0xffBDBDBD)
                                        : colors.colorGrey),
                              )),
                        ],
                      )
                    ]
                    else if( positionBook.posSelection != "All position")...[ CustomTextBtn(
                                label: 'Create Group',
                                onPress: () {
                                   showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return const CreateGroupPos();
                                    });
                                },
                                icon: assets.addCircleIcon)]
                  ],
                ),
              ),
            if (positionBook.showSearchPosition)
              Container(
                height: 62,
                padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
                decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                            color: theme.isDarkMode
                                ? colors.darkGrey
                                : const Color(0xffF1F3F8),
                            width: 6))),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: positionBook.positionSearchCtrl,
                        style: textStyle(
                            theme.isDarkMode
                                ? colors.colorWhite
                                : colors.colorBlack,
                            16,
                            FontWeight.w600),
                        textCapitalization: TextCapitalization.characters,
                        inputFormatters: [
                          UpperCaseTextFormatter(),
                          RemoveEmojiInputFormatter(),
                          FilteringTextInputFormatter.deny(
                              RegExp('[π£•₹€℅™∆√¶/.,]'))
                        ],
                        decoration: InputDecoration(
                            fillColor: theme.isDarkMode
                                ? colors.darkGrey
                                : const Color(0xffF1F3F8),
                            filled: true,
                            hintStyle: GoogleFonts.inter(
                                textStyle: textStyle(const Color(0xff69758F),
                                    15, FontWeight.w500)),
                            prefixIconColor: const Color(0xff586279),
                            prefixIcon: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20.0),
                              child: SvgPicture.asset(assets.searchIcon,
                                  color: const Color(0xff586279),
                                  fit: BoxFit.contain,
                                  width: 20),
                            ),
                            suffixIcon: InkWell(
                              onTap: () async {
                                positionBook.clearPositionSearch();
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0),
                                child: SvgPicture.asset(assets.removeIcon,
                                    fit: BoxFit.scaleDown, width: 20),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(20)),
                            disabledBorder: InputBorder.none,
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(20)),
                            hintText: "Search Scrip Name",
                            contentPadding: const EdgeInsets.only(top: 20),
                            border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(20))),
                        onChanged: (value) async {
                          positionBook.positionSearch(value, context);
                        },
                      ),
                    ),
                    TextButton(
                        onPressed: () {
                          positionBook.showPositionSearch(false);
                        },
                        child: Text("Close",
                            style: textStyles.textBtn.copyWith(
                                color: theme.isDarkMode
                                    ? colors.colorLightBlue
                                    : colors.colorBlue)))
                  ],
                ),
              ),
            positionBook.positionSearchItem.isEmpty
                ? Expanded(
                    child: RefreshIndicator(
                    onRefresh: () async {
                      await positionBook.fetchPositionBook(context, false);
                    },
                    child: ListView(
                      children: [
                        if (listofPosition.isNotEmpty) ...[
                          if (positionBook.posSelection == "Group by symbol")
                            const PositionGroupSymbol()
                          else
                            ListView.separated(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemBuilder: (context, index) {


                                  // The Position  data item list is provided here. These scrips are subscribed to Websocket, and we verify that the conditions fit the Position scrip before adding the data to the Position list.
                      
                                if (socketDatas
                                    .containsKey(listofPosition[index].token)) {
                                  listofPosition[index].lp =
                                      "${socketDatas["${listofPosition[index].token}"]['lp']}";

                                  listofPosition[index].perChange =
                                      "${socketDatas["${listofPosition[index].token}"]['pc']}";

                                  // WidgetsBinding.instance
                                  //     .addPostFrameCallback((_) {
                                  positionBook.positionCal(positionBook.isDay);
                                  // });
                                }
                                return InkWell(
                                    onLongPress: () {
                                      if (positionBook.openPosition!.length >
                                              1 &&
                                          listofPosition[index].qty != "0") {
                                        Navigator.pushNamed(
                                            context, Routes.positionExit,
                                            arguments: listofPosition);
                                      }
                                    },
                                    onTap: () async {
                                      await context
                                          .read(marketWatchProvider)
                                          .fetchLinkeScrip(
                                              "${listofPosition[index].token}",
                                              "${listofPosition[index].exch}",
                                              context);

                                      await watch(marketWatchProvider)
                                          .fetchScripQuote(
                                              "${listofPosition[index].token}",
                                              "${listofPosition[index].exch}",
                                              context);

                                      if ((listofPosition[index].exch ==
                                              "NSE" ||
                                          listofPosition[index].exch ==
                                              "BSE")) {
                                        context
                                            .read(marketWatchProvider)
                                            .depthBtns
                                            .add({
                                          "btnName": "Fundamental",
                                          "imgPath": assets.dInfo,
                                          "case":
                                              "Click here to view fundamental data."
                                        });

                                        await context
                                            .read(marketWatchProvider)
                                            .fetchTechData(
                                                context: context,
                                                exch:
                                                    "${listofPosition[index].exch}",
                                                tradeSym:
                                                    "${listofPosition[index].tsym}",
                                                lastPrc:
                                                    "${listofPosition[index].lp}");
                                      }
                                      Navigator.pushNamed(
                                          context, Routes.positionDetail,
                                          arguments: listofPosition[index]);
                                    },
                                    child: PositionListCard(
                                        positionList: listofPosition[index])

                                    // PositionListCard(
                                    //     positionList:
                                    //         listofPosition[index])),
                                    );
                              },
                              itemCount: listofPosition.length,
                              separatorBuilder:
                                  (BuildContext context, int index) {
                                return Container(
                                    color: theme.isDarkMode
                                        ? listofPosition[index].netqty == "0"
                                            ? colors.colorBlack
                                            : colors.darkGrey
                                        : listofPosition[index].netqty == "0"
                                            ? colors.colorWhite
                                            : const Color(0xffF1F3F8),
                                    height: 6);
                              },
                            )
                        ] else
                          const SizedBox(height: 500, child: NoDataFound())
                      ],
                    ),
                  ))
                : Expanded(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        if (socketDatas.containsKey(
                            positionBook.positionSearchItem[index].token)) {
                          positionBook.positionSearchItem[index].lp =
                              "${socketDatas["${positionBook.positionSearchItem[index].token}"]['lp']}";

                          positionBook.positionSearchItem[index].perChange =
                              "${socketDatas["${positionBook.positionSearchItem[index].token}"]['pc']}";

                          // WidgetsBinding.instance.addPostFrameCallback((_) {
                          //   positionBook.positionCal(positionBook.isDay);
                          // });
                        }
                        return InkWell(
                            onTap: () async {
                              await context.read(marketWatchProvider).fetchLinkeScrip(
                                  "${positionBook.positionSearchItem[index].token}",
                                  "${positionBook.positionSearchItem[index].exch}",
                                  context);

                              await watch(marketWatchProvider).fetchScripQuote(
                                  "${positionBook.positionSearchItem[index].token}",
                                  "${positionBook.positionSearchItem[index].exch}",
                                  context);

                              if ((positionBook
                                          .positionSearchItem[index].exch ==
                                      "NSE" ||
                                  positionBook.positionSearchItem[index].exch ==
                                      "BSE")) {
                                context
                                    .read(marketWatchProvider)
                                    .depthBtns
                                    .add({
                                  "btnName": "Fundamental",
                                  "imgPath": assets.dInfo,
                                  "case": "Click here to view fundamental data."
                                });

                                await context.read(marketWatchProvider).fetchTechData(
                                    context: context,
                                    exch:
                                        "${positionBook.positionSearchItem[index].exch}",
                                    tradeSym:
                                        "${positionBook.positionSearchItem[index].tsym}",
                                    lastPrc:
                                        "${positionBook.positionSearchItem[index].lp}");
                              }
                              Navigator.pushNamed(
                                  context, Routes.positionDetail,
                                  arguments:
                                      positionBook.positionSearchItem[index]);
                            },
                            child: PositionListCard(
                                positionList:
                                    positionBook.positionSearchItem[index]));
                      },
                      itemCount: positionBook.positionSearchItem.length,
                      separatorBuilder: (BuildContext context, int index) {
                        return Container(
                            color: theme.isDarkMode
                                ? positionBook
                                            .positionSearchItem[index].netqty ==
                                        "0"
                                    ? colors.colorBlack
                                    : colors.darkGrey
                                : positionBook
                                            .positionSearchItem[index].netqty ==
                                        "0"
                                    ? colors.colorWhite
                                    : const Color(0xffF1F3F8),
                            height: 6);
                      },
                    ),
                  )
          ]);
  }
}
