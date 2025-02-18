import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/res/res.dart';

import '../../../provider/index_list_provider.dart';

import '../../../provider/market_watch_provider.dart';
import '../../../provider/thems.dart';
import '../../../provider/websocket_provider.dart';
import '../../../sharedWidget/functions.dart';
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
                "${socketDatas["${indexProvide.defaultIndexList!.indValues![index].token}"]['lp'] ?? 0.00}";
            indexProvide.defaultIndexList!.indValues![index].change =
                "${socketDatas["${indexProvide.defaultIndexList!.indValues![index].token}"]['chng'] ?? 0.00}";
            indexProvide.defaultIndexList!.indValues![index].perChange =
                "${socketDatas["${indexProvide.defaultIndexList!.indValues![index].token}"]['pc'] ?? 0.00}";
          }
          return InkWell(
            onTap: () async {
              await context
                  .read(indexListProvider)
                  .fetchIndexList("NSE", context);
              await showModalBottomSheet(
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
              await indexProvide.fetchIndexList("exit", context);
              await context
                  .read(marketWatchProvider)
                  .requestMWScrip(context: context, isSubscribe: true);
            },
            child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 6.0, horizontal: 11),
                decoration: BoxDecoration(
                    color: theme.isDarkMode
                        ? const Color(0xffB5C0CF).withOpacity(.15)
                        : const Color(0xffF1F3F8),
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
                              theme.isDarkMode
                                  ? const Color(0xffB5C0CF)
                                  : const Color(0xff000000),
                              14,
                              FontWeight.w600),
                        ),
                      ),
                      Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                                "₹${indexProvide.defaultIndexList!.indValues![index].ltp ?? 0.00}",
                                style: textStyle(
                                    theme.isDarkMode
                                        ? const Color(0xffE5E5E5)
                                        : const Color(0xff000000),
                                    13,
                                    FontWeight.w600)),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Text(
                                    "${indexProvide.defaultIndexList!.indValues![index].change == "null" ? 0.00 : indexProvide.defaultIndexList!.indValues![index].change} ",
                                    style: textStyle(
                                        (indexProvide
                                                        .defaultIndexList!
                                                        .indValues![index]
                                                        .change ==
                                                    "null") ||
                                                (indexProvide
                                                        .defaultIndexList!
                                                        .indValues![index]
                                                        .change ==
                                                    "0.00")
                                            ? colors.ltpgrey
                                            : indexProvide.defaultIndexList!
                                                    .indValues![index].change!
                                                    .startsWith("-")
                                                ? colors.darkred
                                                : colors.ltpgreen,
                                        12,
                                        FontWeight.w600)),
                                Text(
                                  "(${indexProvide.defaultIndexList!.indValues![index].perChange == "null" ? 0.00 : indexProvide.defaultIndexList!.indValues![index].perChange}%)",
                                  style: textStyle(
                                      (indexProvide
                                                      .defaultIndexList!
                                                      .indValues![index]
                                                      .perChange ==
                                                  "null") ||
                                              (indexProvide
                                                      .defaultIndexList!
                                                      .indValues![index]
                                                      .perChange ==
                                                  "0.00")
                                          ? colors.ltpgrey
                                          : indexProvide.defaultIndexList!
                                                  .indValues![index].perChange!
                                                  .startsWith('-')
                                              ? colors.darkred
                                              : colors.ltpgreen,
                                      12,
                                      FontWeight.w600),
                                ),
                              ],
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
}
