import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart'; 

import '../../../provider/index_list_provider.dart';

import '../../../provider/thems.dart';
import '../../../provider/websocket_provider.dart';
import 'index_bottom_sheet.dart';

class DefaultIndexList extends ConsumerWidget {
  const DefaultIndexList({super.key});

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final socketDatas = watch(websocketProvider).socketDatas;
    final indexProvide = watch(indexListProvider);
    final theme = context.read(themeProvider);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.only(left: 14),
      height: 50,
      child: ListView.separated(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: indexProvide.defaultIndexList!.indValues!.length,
        itemBuilder: (BuildContext context, int index) {
          if (socketDatas.containsKey(
              indexProvide.defaultIndexList!.indValues![index].token)) {
            indexProvide.defaultIndexList!.indValues![index].ltp =
                "${socketDatas["${indexProvide.defaultIndexList!.indValues![index].token}"]['lp']}";
            indexProvide.defaultIndexList!.indValues![index].change =
                "${socketDatas["${indexProvide.defaultIndexList!.indValues![index].token}"]['chng']}";
            indexProvide.defaultIndexList!.indValues![index].perChange =
                "${socketDatas["${indexProvide.defaultIndexList!.indValues![index].token}"]['pc']}";
          }
          return
              // ShowCaseView(
              //    showtour: true,
              //   nip: BubbleNip.leftTop,
              //   margin: const EdgeInsets.only(left: 40),
              //   index: 0,
              //   text: "Click here to view all index list.",
              //   globalKey: index == 0
              //       ? context.read(showcaseProvide).indexcardcase
              //       : GlobalKey(debugLabel: "$index"),
              //   postion: TooltipPosition.bottom,
              //   childs:

              InkWell(
            onTap: () async {
              await context
                  .read(indexListProvider)
                  .fetchIndexList("NSE", context);
              // _showSimpleDialog(context, widget.indexProvide, index);
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
                  builder: (_) => IndexBottomSheet(defaultIndex: index));
            },
            child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 6.0, horizontal: 11),
                decoration: BoxDecoration(
                    color:theme .isDarkMode? const Color(0xffB5C0CF).withOpacity(.15): const Color(0xffF1F3F8),
                    borderRadius: BorderRadius.circular(5)),
                width: MediaQuery.of(context).size.width * 0.47,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          indexProvide
                              .defaultIndexList!.indValues![index].idxname!
                              .toUpperCase(),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: textStyle(
                           theme .isDarkMode?const Color(0xffB5C0CF):   const Color(0xff000000), 14, FontWeight.w600),
                        ),
                      ),
                      Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                                "₹${indexProvide.defaultIndexList!.indValues![index].ltp ?? 0.00}",
                                style: textStyle( theme .isDarkMode?const Color(0xffE5E5E5):const Color(0xff000000), 13,
                                    FontWeight.w600)),
                            const SizedBox(height: 2),
                            Text(
                              "${indexProvide.defaultIndexList!.indValues![index].change=="null" ?0.00 :indexProvide.defaultIndexList!.indValues![index].change} (${indexProvide.defaultIndexList!.indValues![index].perChange=="null" ?0.00:indexProvide.defaultIndexList!.indValues![index].perChange}%)",
                              style: textStyle(
                                  Color((indexProvide
                                                      .defaultIndexList!
                                                      .indValues![index]
                                                      .change ==
                                                  "null" ||
                                              indexProvide
                                                      .defaultIndexList!
                                                      .indValues![index]
                                                      .perChange ==
                                                  "null") ||
                                          (indexProvide
                                                      .defaultIndexList!
                                                      .indValues![index]
                                                      .change ==
                                                  "0.00" ||
                                              indexProvide
                                                      .defaultIndexList!
                                                      .indValues![index]
                                                      .perChange ==
                                                  "0.00")
                                      ? 0xff999999
                                      : indexProvide.defaultIndexList!
                                                  .indValues![index].change!
                                                  .startsWith("-") ||
                                              indexProvide.defaultIndexList!
                                                  .indValues![index].perChange!
                                                  .startsWith('-')
                                          ? 0xffFF1717
                                          : 0xff43A833),
                                  12,
                                  FontWeight.w600),
                            )
                          ])
                    ])

                //  DefaultIndexListCard(
                //   indVal: widget.indexProvide.defaultIndexList!.indValues![index],
                // ),
                ),
            // ),
          );
        },
        separatorBuilder: (BuildContext context, int index) {
          return const SizedBox(width: 9);
        },
      ),
    );
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
        textStyle:
            TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize));
  }
}
