import 'package:flutter/material.dart';
import 'package:flutter_expanded_tile/flutter_expanded_tile.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../provider/market_watch_provider.dart';
import '../../../../provider/portfolio_provider.dart';
import '../../../../provider/thems.dart';
import '../../../../provider/websocket_provider.dart';
import '../../../../res/res.dart';
import '../../../../res/global_state_text.dart';
import '../../../../routes/route_names.dart';
import '../../../../sharedWidget/custom_text_btn.dart';
import '../../../../sharedWidget/functions.dart';
import 'position_group_listcard.dart';
import 'positionlist_bottom_sheet.dart';

class PositionGroupSymbol extends ConsumerWidget {
  const PositionGroupSymbol({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final positionBook = ref.watch(portfolioProvider);
    final theme = ref.read(themeProvider);
    
    return positionBook.loading
        ? const Center(child: CircularProgressIndicator())
        : StreamBuilder<Map>(
            stream: ref.watch(websocketProvider).socketDataStream,
            builder: (context, snapshot) {
              final socketDatas = snapshot.data ?? {};
              
              // Update positions with real-time data
              if (snapshot.hasData) {
                for (int groupIndex = 0; groupIndex < positionBook.groupPositionSym.length; groupIndex++) {
                  final groupSymbol = positionBook.groupPositionSym[groupIndex];
                  final groupList = positionBook.groupedBySymbol[groupSymbol]['groupList'];
                  
                  // Update each position in the group
                  for (var i = 0; i < groupList.length; i++) {
                    final token = groupList[i]['token'];
                    if (socketDatas.containsKey(token)) {
                      final lp = socketDatas[token]['lp']?.toString();
                      final pc = socketDatas[token]['pc']?.toString();
                      final chng = socketDatas[token]['chng']?.toString();
                      
                      if (lp != null && lp != "null") {
                        groupList[i]['lp'] = lp;
                      }
                      
                      if (pc != null && pc != "null") {
                        groupList[i]['perChange'] = pc;
                      }
                      
                      if (chng != null && chng != "null") {
                        groupList[i]['chng'] = chng;
                      }
                    }
                  }
                  
                  // Recalculate group totals
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    positionBook.positionGroupCal(
                      positionBook.isDay,
                      groupList,
                      groupSymbol,
                      positionBook.groupedBySymbol[groupSymbol]["isCustomGrp"]);
                  });
                }
              }
              
              return ExpandedTileList.separated(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                itemCount: positionBook.groupPositionSym.length,
                maxOpened: positionBook.groupPositionSym.length,
                shrinkWrap: true,
                itemBuilder: (context, index, controller) {
                  return ExpandedTile(
                      theme: ExpandedTileThemeData(
                          headerColor: theme.isDarkMode
                              ? const Color(0xffB5C0CF).withOpacity(.15)
                              : const Color(0xffF1F3F8),
                          headerPadding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 0),
                          contentBackgroundColor: const Color(0xffF1F3F8),
                          contentPadding: const EdgeInsets.all(0),
                          trailingPadding: const EdgeInsets.all(0)),
                      controller: controller,
                      title: Column(children: [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                                TextWidget.subText(
                                    text:
                                  "${positionBook.groupPositionSym[index]}(${positionBook.groupedBySymbol[positionBook.groupPositionSym[index]]['groupList'].length})",
                                    theme: theme.isDarkMode,
                                    fw: 1),
                              Column(children: [
                                Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Row(children: [
                                          TextWidget.paraText(
                                              text: positionBook.isNetPnl
                                                ? "Grouped P&L: "
                                                : "Grouped MTM: ",
                                              theme: theme.isDarkMode,
                                              color: const Color(0xff5E6B7D),
                                              fw: 0),
                                          TextWidget.subText(
                                              text:
                                            "${positionBook.isNetPnl ? positionBook.groupedBySymbol[positionBook.groupPositionSym[index]]['totPnl'] : positionBook.groupedBySymbol[positionBook.groupPositionSym[index]]['totMtm']}",
                                              theme: theme.isDarkMode,
                                              color: positionBook.isNetPnl
                                                  ? positionBook
                                                          .groupedBySymbol[
                                                                positionBook
                                                                        .groupPositionSym[
                                                                    index]]
                                                                ['totPnl']
                                                            .toString()
                                                            .startsWith("-")
                                                        ? colors.darkred
                                                        : colors.ltpgreen
                                                    : positionBook.groupedBySymbol[
                                                                positionBook
                                                                        .groupPositionSym[
                                                                    index]]
                                                                ['totMtm']
                                                            .toString()
                                                            .startsWith('-')
                                                        ? colors.darkred
                                                        : colors.ltpgreen,
                                              fw: 1)
                                      ])
                                    ])
                              ])
                            ])
                      ]),
                      content: Column(children: [
                        Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            child: Row(
                                mainAxisAlignment: positionBook.groupedBySymbol[
                                                positionBook
                                                    .groupPositionSym[index]]
                                            ['isexit'] ==
                                        "true"
                                    ? MainAxisAlignment.spaceBetween
                                    : MainAxisAlignment.end,
                                children: [
                                  if (positionBook.groupedBySymbol[positionBook.groupPositionSym[index]]
                                          ['isexit'] ==
                                      "true")
                                    // Container(
                                    //     decoration: BoxDecoration(
                                    //         border: Border(
                                    //             bottom: BorderSide(
                                    //                 color: theme.isDarkMode
                                    //                     ? colors.darkGrey
                                    //                     : const Color(0xffF1F3F8),
                                    //                 width: 6))),
                                    //     child: SizedBox(
                                    //         height: 27,
                                    //         child: OutlinedButton(
                                    //             onPressed: () {
                                    //               showDialog(
                                    //                   context: context,
                                    //                   builder:
                                    //                       (BuildContext context) {
                                    //                     return AlertDialog(
                                    //                         backgroundColor: theme.isDarkMode
                                    //                             ? const Color.fromARGB(
                                    //                                 255, 18, 18, 18)
                                    //                             : colors.colorWhite,
                                    //                         titleTextStyle: textStyles
                                    //                             .appBarTitleTxt
                                    //                             .copyWith(
                                    //                                 color: theme.isDarkMode
                                    //                                     ? colors
                                    //                                         .colorWhite
                                    //                                     : colors
                                    //                                         .colorBlack),
                                    //                         contentTextStyle: textStyles
                                    //                             .menuTxt
                                    //                             .copyWith(
                                    //                                 color: theme.isDarkMode
                                    //                                     ? colors
                                    //                                         .colorWhite
                                    //                                     : colors
                                    //                                         .colorBlack),
                                    //                         titlePadding:
                                    //                             const EdgeInsets.symmetric(
                                    //                                 horizontal: 14,
                                    //                                 vertical: 12),
                                    //                         shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(14))),
                                    //                         scrollable: true,
                                    //                         contentPadding: const EdgeInsets.symmetric(
                                    //                           horizontal: 14,
                                    //                         ),
                                    //                         insetPadding: const EdgeInsets.symmetric(horizontal: 20),
                                    //                         title: const Text("Exit Position"),
                                    //                         content: SizedBox(width: MediaQuery.of(context).size.width, child: Text("Are you sure you want to exit all positions in the ${positionBook.groupPositionSym[index]} group?")),
                                    //                         actions: [
                                    //                           TextButton(
                                    //                               onPressed: () =>
                                    //                                   Navigator.of(
                                    //                                           context)
                                    //                                       .pop(),
                                    //                               child: Text("No",
                                    //                                   style: textStyles
                                    //                                       .textBtn
                                    //                                       .copyWith(
                                    //                                           color: theme.isDarkMode
                                    //                                               ? colors.colorLightBlue
                                    //                                               : colors.colorBlue))),
                                    //                           ElevatedButton(
                                    //                               onPressed:
                                    //                                   () async {
                                    //                                 await positionBook.exitGroupedPosition(
                                    //                                     context,
                                    //                                     positionBook
                                    //                                         .groupedBySymbol[positionBook
                                    //                                             .groupPositionSym[
                                    //                                         index]]['groupList']);
                                    //                                 Navigator.of(
                                    //                                         context)
                                    //                                     .pop(true);
                                    //                               },
                                    //                               style: ElevatedButton
                                    //                                   .styleFrom(
                                    //                                       elevation:
                                    //                                           0,
                                    //                                       backgroundColor: theme.isDarkMode
                                    //                                           ? colors
                                    //                                               .colorbluegrey
                                    //                                           : colors
                                    //                                               .colorBlack,
                                    //                                       shape:
                                    //                                           RoundedRectangleBorder(
                                    //                                         borderRadius:
                                    //                                             BorderRadius.circular(50),
                                    //                                       )),
                                    //                               child: Text("Yes",
                                    //                                   style: textStyle(
                                    //                                       !theme.isDarkMode
                                    //                                           ? colors
                                    //                                               .colorWhite
                                    //                                           : colors
                                    //                                               .colorBlack,
                                    //                                       14,
                                    //                                       FontWeight
                                    //                                           .w500)))
                                    //                         ]);
                                    //                   });
                                    //             },
                                    //             style: OutlinedButton.styleFrom(
                                    //                 side: BorderSide(
                                    //                     color: theme.isDarkMode
                                    //                         ? colors.colorGrey
                                    //                         : colors.colorBlack),
                                    //                 shape: const RoundedRectangleBorder(
                                    //                     borderRadius: BorderRadius.all(
                                    //                         Radius.circular(32)))),
                                    //             child: Text("Exit",
                                    //                 style: textStyle(
                                    //                     theme.isDarkMode ? colors.colorWhite : colors.colorBlack, 12, FontWeight.w600))))),
                                  
                                  if (positionBook.groupedBySymbol[positionBook
                                      .groupPositionSym[index]]["isCustomGrp"])
                                    Row(children: [
                                      CustomTextBtn(
                                          label: 'Add symbol',
                                          onPress: () async {
                                            await positionBook.cusGrpSelectPosition(
                                                positionBook.groupedBySymbol[
                                                    positionBook.groupPositionSym[
                                                        index]]['groupList']);
                                            showModalBottomSheet(
                                                context: context,
                                                isScrollControlled: true,
                                                isDismissible: true,
                                                shape: const RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.only(
                                                    topLeft: Radius.circular(10),
                                                    topRight: Radius.circular(10),
                                                  ),
                                                ),
                                                builder: (_) =>
                                                    PositionListBottomSheet(
                                                        grpName: positionBook
                                                                .groupPositionSym[
                                                            index]));
                                          },
                                          icon: assets.addCircleIcon),
                                      InkWell(
                                          child: const Icon(
                                            Icons.delete_outlined,
                                            color: Color(0xff666666),
                                          ),
                                          onTap: () async {
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  backgroundColor: theme.isDarkMode
                                                      ? const Color.fromARGB(
                                                          255, 18, 18, 18)
                                                      : colors.colorWhite,
                                                      titleTextStyle:
                                                          TextWidget.textStyle(
                                                              fontSize: 16,
                                                          color: theme.isDarkMode
                                                                  ? colors
                                                                      .colorWhite
                                                                  : colors
                                                                      .colorBlack,
                                                              theme: theme
                                                                  .isDarkMode,
                                                              fw: 1),
                                                  contentTextStyle:
                                                          TextWidget.textStyle(
                                                              fontSize: 12,
                                                          color: theme.isDarkMode
                                                                  ? colors
                                                                      .colorWhite
                                                                  : colors
                                                                      .colorBlack,
                                                              theme: theme
                                                                  .isDarkMode,
                                                              fw: 1),
                                                  titlePadding:
                                                      const EdgeInsets.symmetric(
                                                          horizontal: 14,
                                                          vertical: 12),
                                                  shape:
                                                      const RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius.circular(
                                                                      14))),
                                                  scrollable: true,
                                                  contentPadding:
                                                      const EdgeInsets.symmetric(
                                                    horizontal: 14,
                                                  ),
                                                  insetPadding:
                                                      const EdgeInsets.symmetric(
                                                          horizontal: 20),
                                                      title:
                                                          TextWidget.titleText(
                                                              text:
                                                                  "Delete Group",
                                                              theme: theme
                                                                  .isDarkMode,
                                                              fw: 1),
                                                  content: SizedBox(
                                                    width: MediaQuery.of(context)
                                                        .size
                                                        .width,
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment.start,
                                                      children: [
                                                            TextWidget.paraText(
                                                                text:
                                                                    "Are you sure you want to Delete Group of ${positionBook.groupPositionSym[index]}?",
                                                                theme: theme
                                                                    .isDarkMode,
                                                                fw: 0)
                                                      ],
                                                    ),
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                        onPressed: () =>
                                                            Navigator.of(context)
                                                                .pop(),
                                                            child: TextWidget.paraText(
                                                                text: "No",
                                                                theme: theme
                                                                    .isDarkMode,
                                                                color: theme.isDarkMode
                                                                    ? colors
                                                                        .colorLightBlue
                                                                    : colors  
                                                                        .colorBlue,
                                                                fw: 0)),
                                                    ElevatedButton(
                                                      onPressed: () async {
                                                        await positionBook
                                                            .fetchDeleteGroupName(
                                                                positionBook
                                                                        .groupPositionSym[
                                                                    index],
                                                                context);

                                                        Navigator.of(context)
                                                            .pop(true);
                                                      },
                                                      style:
                                                          ElevatedButton.styleFrom(
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
                                                          child: TextWidget.subText(
                                                              text: "Yes",
                                                              theme: theme
                                                                  .isDarkMode,
                                                              color: !theme
                                                                      .isDarkMode
                                                                  ? colors
                                                                      .colorWhite
                                                                  : colors
                                                                      .colorBlack,
                                                              fw: 0),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          })
                                    ])
                                  ])),
                          ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: positionBook
                                  .groupedBySymbol[positionBook
                                      .groupPositionSym[index]]['groupList']
                                  .length,
                              separatorBuilder: (BuildContext context, int ind) {
                                return Container(
                                    color: theme.isDarkMode
                                        ? positionBook.groupedBySymbol[positionBook
                                                        .groupPositionSym[index]]
                                                    ['groupList']![ind]['qty'] ==
                                                "0"
                                            ? colors.colorBlack
                                            : colors.darkGrey
                                        : positionBook.groupedBySymbol[positionBook
                                                        .groupPositionSym[index]]
                                                    ['groupList']![ind]['qty'] ==
                                                "0"
                                            ? colors.colorWhite
                                            : const Color(0xffF1F3F8),
                                    height: 6);
                              },
                              itemBuilder: (BuildContext context, int ind) {
                                return InkWell(
                                    onTap: () async {
                                      await ref.read(marketWatchProvider).fetchLinkeScrip(
                                          "${positionBook.groupedBySymbol[positionBook.groupPositionSym[index]]['groupList']![ind]['token']}",
                                          "${positionBook.groupedBySymbol[positionBook.groupPositionSym[index]]['groupList']![ind]['exch']}",
                                          context);

                                      await ref.watch(marketWatchProvider).fetchScripQuote(
                                          "${positionBook.groupedBySymbol[positionBook.groupPositionSym[index]]['groupList']![ind]['token']}",
                                          "${positionBook.groupedBySymbol[positionBook.groupPositionSym[index]]['groupList']![ind]['exch']}",
                                          context);

                                      if ((positionBook.groupedBySymbol[positionBook
                                                      .groupPositionSym[index]]
                                                  ['groupList']![ind]['exch'] ==
                                              "NSE" ||
                                          positionBook.groupedBySymbol[positionBook
                                                      .groupPositionSym[index]]
                                                  ['groupList']![ind]['exch'] ==
                                              "BSE")) {
                                        ref.read(marketWatchProvider)
                                            .depthBtns
                                            .add({
                                          "btnName": "Fundamental",
                                          "imgPath": assets.dInfo,
                                          "case":
                                              "Click here to view fundamental data."
                                        });

                                        await ref.read(marketWatchProvider).fetchTechData(
                                            context: context,
                                            exch:
                                                "${positionBook.groupedBySymbol[positionBook.groupPositionSym[index]]['groupList']![ind]['exch']}",
                                            tradeSym:
                                                "${positionBook.groupedBySymbol[positionBook.groupPositionSym[index]]['groupList']![ind]['tsym']}",
                                            lastPrc:
                                                "${positionBook.groupedBySymbol[positionBook.groupPositionSym[index]]['groupList']![ind]['lp']}");
                                      }
                                      Navigator.pushNamed(
                                          context, Routes.positionGroupDetail,
                                          arguments: positionBook.groupedBySymbol[
                                                  positionBook
                                                      .groupPositionSym[index]]
                                              ['groupList']![ind]);
                                    },
                                    child: PositionListGrpCard(
                                        groupData: positionBook.groupedBySymbol[
                                                positionBook.groupPositionSym[index]]
                                            ['groupList']![ind]));
                              })
                        ]));
                },
                separatorBuilder: (BuildContext context, int index) {
                  return Container(height: 8);
                });
            });
  }
}
