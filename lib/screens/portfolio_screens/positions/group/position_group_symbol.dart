import 'package:flutter/material.dart';
import 'package:flutter_expanded_tile/flutter_expanded_tile.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';  
import '../../../../provider/portfolio_provider.dart';
import '../../../../provider/thems.dart';
import '../../../../provider/websocket_provider.dart';
import '../../../../res/res.dart'; 
import '../../../../sharedWidget/functions.dart'; 
import 'position_group_listcard.dart'; 

class PositionGroupSymbol extends ConsumerWidget { 
  const PositionGroupSymbol({super.key });

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final positionBook = watch(portfolioProvider);
    final socketDatas = watch(websocketProvider).socketDatas;
    final theme = context.read(themeProvider);
    return   ExpandedTileList.separated(
      
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              itemCount: positionBook.groupPositionSym.length,
                        maxOpened: positionBook.groupPositionSym.length,
                              shrinkWrap: true,
                              itemBuilder: (context, index, controller) {
                                return ExpandedTile( 
                                  
                                    trailingRotation: 90,
                                    theme: ExpandedTileThemeData(
                                        headerColor: theme.isDarkMode
                                            ? const Color(0xffB5C0CF)
                                                .withOpacity(.15)
                                            : const Color(0xffF1F3F8),
                                        headerPadding: EdgeInsets.symmetric(
                                            vertical: 8, horizontal: 0),
                                        //   headerSplashColor: Colors.red,
                                        contentBackgroundColor:
                                            Color(0xffF1F3F8),
                                        contentPadding: EdgeInsets.all(0),
                                        //   contentRadius: 12.0,
                                        trailingPadding: EdgeInsets.all(0)),
                                    controller: controller,
                                    title: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "${positionBook.groupPositionSym[index]}(${positionBook.groupedBySymbol[positionBook.groupPositionSym[index]]['groupList'].length})",
                                            style: textStyle(
                                                theme.isDarkMode
                                                    ? colors.colorWhite
                                                    : colors.colorBlack,
                                                14,
                                                FontWeight.w600),
                                          ),
                                          Column(children: [
                                            Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  Row(children: [
                                                    Text(
                                                        positionBook.isNetPnl
                                                            ? "Total P&L: "
                                                            : "Total MTM: ",
                                                        style: textStyle(
                                                            const Color(
                                                                0xff5E6B7D),
                                                            12,
                                                            FontWeight.w500)),
                                                    Text(
                                                        "${positionBook.isNetPnl ? positionBook.groupedBySymbol[positionBook.groupPositionSym[index]]['totPnl'] : positionBook.groupedBySymbol[positionBook.groupPositionSym[index]]['totMtm']}",
                                                        style: textStyle(
                                                            theme.isDarkMode
                                                                ? colors
                                                                    .colorWhite
                                                                : colors
                                                                    .colorBlack,
                                                            14,
                                                            FontWeight.w500))
                                                  ])
                                                ])
                                          ])
                                        ]),
                                    content: ListView.separated(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount: positionBook
                                            .groupedBySymbol[positionBook
                                                    .groupPositionSym[index]]
                                                ['groupList']
                                            .length,
                                        separatorBuilder:
                                            (BuildContext context, int ind) {
                                          return Container(height: 10);
                                        },
                                        itemBuilder:
                                            (BuildContext context, int ind) {
                                          if (socketDatas.containsKey(
                                              positionBook.groupedBySymbol[
                                                      positionBook
                                                              .groupPositionSym[
                                                          index]]['groupList']![
                                                  ind]['token'])) {
                                            positionBook.groupedBySymbol[
                                                        positionBook
                                                                .groupPositionSym[
                                                            index]]
                                                    ['groupList']![ind]['lp'] =
                                                "${socketDatas["${positionBook.groupedBySymbol[positionBook.groupPositionSym[index]]['groupList']![ind]['token']}"]['lp']}";

                                            positionBook.groupedBySymbol[
                                                        positionBook
                                                                .groupPositionSym[
                                                            index]]['groupList']![
                                                    ind]['perChange'] =
                                                "${socketDatas["${positionBook.groupedBySymbol[positionBook.groupPositionSym[index]]['groupList']![ind]['token']}"]['pc']}";

                                            // WidgetsBinding.instance
                                            //     .addPostFrameCallback((_) {
                                            positionBook.positionGroupCal(
                                                positionBook.isDay,
                                                positionBook
                                                    .groupedBySymbol[positionBook
                                                        .groupPositionSym[
                                                    index]]['groupList']![ind]);
                                            // });
                                          }

                                          return PositionListGrpCard(
                                              groupData: positionBook
                                                  .groupedBySymbol[positionBook
                                                      .groupPositionSym[
                                                  index]]['groupList']![ind]);
                                        }));
                              },
                              separatorBuilder:
                                  (BuildContext context, int index) {
                                return Container(height: 10);
                              },
                            );
    
    
    
    
    
    // ListView.separated(
    //             physics: const NeverScrollableScrollPhysics(),
    //             shrinkWrap: true,
    //             itemBuilder: (context, index) {
    //               return Column(children: [
    //                 Container(
    //                     padding: const EdgeInsets.all(10),
    //                     color: theme.isDarkMode
    //                         ? const Color(0xffB5C0CF)
    //                             .withOpacity(.15)
    //                         : const Color(0xffF1F3F8),
    //                     child: Row(
    //                         mainAxisAlignment:
    //                             MainAxisAlignment.spaceBetween,
    //                         children: [
    //                           Text(
    //                             positionBook
    //                                 .groupPositionSym[index],
    //                             style: textStyle(
    //                                 theme.isDarkMode
    //                                     ? colors.colorWhite
    //                                     : colors.colorBlack,
    //                                 16,
    //                                 FontWeight.w600),
    //                           ),
    //                           Column(children: [
    //                             Column(
    //                                 crossAxisAlignment:
    //                                     CrossAxisAlignment.end,
    //                                 children: [
    //                                   Row(children: [
    //                                     Text(
    //                                         positionBook
    //                                                 .isNetPnl
    //                                             ? "Total P&L: "
    //                                             : "Total MTM: ",
    //                                         style: textStyle(
    //                                             const Color(
    //                                                 0xff5E6B7D),
    //                                             12,
    //                                             FontWeight
    //                                                 .w500)),
    //                                     Text(
    //                                         "${positionBook.isNetPnl ? positionBook.groupedBySymbol[positionBook.groupPositionSym[index]]['totPnl'] : positionBook.groupedBySymbol[positionBook.groupPositionSym[index]]['totMtm']}",
    //                                         style: textStyle(
    //                                             theme.isDarkMode
    //                                                 ? colors
    //                                                     .colorWhite
    //                                                 : colors
    //                                                     .colorBlack,
    //                                             14,
    //                                             FontWeight
    //                                                 .w500))
    //                                   ])
    //                                 ])
    //                           ])
    //                         ])),
    //                 ListView.separated(
    //                     shrinkWrap: true,
    //                     physics:
    //                         const NeverScrollableScrollPhysics(),
    //                     itemCount: positionBook
    //                         .groupedBySymbol[positionBook
    //                                 .groupPositionSym[index]]
    //                             ['groupList']
    //                         .length,
    //                     separatorBuilder:
    //                         (BuildContext context, int ind) {
    //                       return Container(height: 10);
    //                     },
    //                     itemBuilder:
    //                         (BuildContext context, int ind) {
    //                       if (socketDatas.containsKey(
    //                           positionBook.groupedBySymbol[
    //                                   positionBook
    //                                           .groupPositionSym[
    //                                       index]]['groupList']![
    //                               ind]['token'])) {
    //                         positionBook.groupedBySymbol[
    //                                     positionBook
    //                                             .groupPositionSym[
    //                                         index]]
    //                                 ['groupList']![ind]['lp'] =
    //                             "${socketDatas["${positionBook.groupedBySymbol[positionBook.groupPositionSym[index]]['groupList']![ind]['token']}"]['lp']}";
            
    //                         positionBook.groupedBySymbol[
    //                                     positionBook
    //                                             .groupPositionSym[
    //                                         index]]['groupList']![
    //                                 ind]['perChange'] =
    //                             "${socketDatas["${positionBook.groupedBySymbol[positionBook.groupPositionSym[index]]['groupList']![ind]['token']}"]['pc']}";
            
    //                         // WidgetsBinding.instance
    //                         //     .addPostFrameCallback((_) {
    //                         positionBook.positionGroupCal(
    //                             positionBook.isDay,
    //                             positionBook
    //                                 .groupedBySymbol[positionBook
    //                                     .groupPositionSym[
    //                                 index]]['groupList']![ind]);
    //                         // });
    //                       }
            
    //                       return PositionListGrpCard(
    //                           groupData: positionBook
    //                               .groupedBySymbol[positionBook
    //                                   .groupPositionSym[
    //                               index]]['groupList']![ind]);
    //                     })
    //               ]);
    //             },
    //             itemCount: positionBook.groupPositionSym.length,
    //             separatorBuilder:
    //                 (BuildContext context, int index) {
    //               return Container(height: 10);
    //             },
    //           )
    //        ;
 
 
  }
}
