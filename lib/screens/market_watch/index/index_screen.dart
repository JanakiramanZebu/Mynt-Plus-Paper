// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/res/res.dart';

import '../../../models/marketwatch_model/get_quotes.dart';
import '../../../provider/index_list_provider.dart';
import '../../../provider/market_watch_provider.dart';
import '../../../provider/thems.dart';
import '../../../provider/websocket_provider.dart';
import '../../../sharedWidget/functions.dart';
import 'index_bottom_sheet.dart';

class DefaultIndexList extends ConsumerWidget {
  bool src;
  DefaultIndexList({super.key, required this.src});
  
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final indexProvide = watch(indexListProvider);
    final theme = context.read(themeProvider);
    
    return StreamBuilder<Map>(
      stream: watch(websocketProvider).socketDataStream,
      builder: (context, snapshot) {
        final socketDatas = snapshot.data ?? {};
        
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: EdgeInsets.only(left: src ? 0 : 12),
          height: src ? 54 : 50,
          child: ListView.separated(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: indexProvide.defaultIndexList!.indValues!.length,
            itemBuilder: (BuildContext context, int index) {
              // Create a copy to avoid modifying the original data
              var displayData = indexProvide.defaultIndexList!.indValues![index];
              
              // Update with socket data if available
              if (socketDatas.containsKey(displayData.token)) {
                final socketData = socketDatas[displayData.token];
                
                // Only update with valid values
                final lp = socketData['lp']?.toString();
                if (lp != null && lp != "null" && lp != "0" && lp != "0.00") {
                  displayData.ltp = lp;
                }
                
                final chng = socketData['chng']?.toString();
                if (chng != null && chng != "null") {
                  displayData.change = chng;
                }
                
                final pc = socketData['pc']?.toString();
                if (pc != null && pc != "null") {
                  displayData.perChange = pc;
                }
              }
              
              return InkWell(
                onTap: () async {
                  await context.read(marketWatchProvider).fetchScripQuoteIndex(
                      displayData.token.toString(),
                      displayData.exch.toString(),
                      context);

                  final quots = context.read(marketWatchProvider).getQuotes;
                  DepthInputArgs depthArgs = DepthInputArgs(
                      exch: quots!.exch.toString(),
                      token: quots.token.toString(),
                      tsym: quots.tsym.toString(),
                      instname: quots.instname.toString(),
                      symbol: quots.symbol.toString(),
                      expDate: quots.expDate.toString(),
                      option: quots.option.toString());
                  await context
                      .read(marketWatchProvider)
                      .calldepthApis(context, depthArgs, "");
                },
                onLongPress: () async {
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
                      builder: (_) =>
                          IndexBottomSheet(defaultIndex: index, src: src));
                  await indexProvide.fetchIndexList("exit", context);
                  await context
                      .read(marketWatchProvider)
                      .requestMWScrip(context: context, isSubscribe: true);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: theme.isDarkMode
                          ? colors.darkColorDivider
                          : colors.colorDivider,
                      width: src ? 0.6 : 0
                    ),
                    color: src
                        ? Colors.transparent
                        : theme.isDarkMode
                            ? const Color(0xffB5C0CF).withOpacity(.15)
                            : const Color(0xffF1F3F8),
                    borderRadius: BorderRadius.circular(5)
                  ),
                  width: MediaQuery.of(context).size.width * 0.47,
                  child: src
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayData.idxname!.toUpperCase(),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: textStyle(
                                theme.isDarkMode
                                    ? const Color(0xffB5C0CF)
                                    : const Color(0xff000000),
                                14,
                                FontWeight.w600),
                          ),
                          const SizedBox(height: 6),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "₹${displayData.ltp ?? 0.00}",
                                  style: textStyle(
                                      theme.isDarkMode
                                          ? const Color(0xffE5E5E5)
                                          : const Color(0xff666666),
                                      13,
                                      FontWeight.w600)
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "${displayData.change == "null" ? 0.00 : displayData.change} ",
                                  style: textStyle(
                                      (displayData.change == "null") ||
                                              (displayData.change == "0.00")
                                          ? colors.ltpgrey
                                          : displayData.change!.startsWith("-")
                                              ? colors.darkred
                                              : colors.ltpgreen,
                                      12,
                                      FontWeight.w600)
                                ),
                                Text(
                                  "(${displayData.perChange == "null" ? 0.00 : displayData.perChange}%)",
                                  style: textStyle(
                                      (displayData.perChange == "null") ||
                                              (displayData.perChange == "0.00")
                                          ? colors.ltpgrey
                                          : displayData.perChange!.startsWith('-')
                                              ? colors.darkred
                                              : colors.ltpgreen,
                                      12,
                                      FontWeight.w600),
                                )
                              ]
                            ),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              displayData.idxname!.toUpperCase(),
                              maxLines: 1,
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
                                "₹${displayData.ltp ?? 0.00}",
                                style: textStyle(
                                    theme.isDarkMode
                                        ? const Color(0xffE5E5E5)
                                        : const Color(0xff000000),
                                    13,
                                    FontWeight.w600)
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    "${displayData.change == "null" ? 0.00 : displayData.change} ",
                                    style: textStyle(
                                        (displayData.change == "null") ||
                                                (displayData.change == "0.00")
                                            ? colors.ltpgrey
                                            : displayData.change!.startsWith("-")
                                                ? colors.darkred
                                                : colors.ltpgreen,
                                        12,
                                        FontWeight.w600)
                                  ),
                                  Text(
                                    "(${displayData.perChange == "null" ? 0.00 : displayData.perChange}%)",
                                    style: textStyle(
                                        (displayData.perChange == "null") ||
                                                (displayData.perChange == "0.00")
                                            ? colors.ltpgrey
                                            : displayData.perChange!.startsWith('-')
                                                ? colors.darkred
                                                : colors.ltpgreen,
                                        12,
                                        FontWeight.w600),
                                  ),
                                ],
                              )
                            ],
                          )
                        ],
                      ),
                ),
              );
            },
            separatorBuilder: (BuildContext context, int index) {
              return const SizedBox(width: 9);
            },
          ),
        );
      },
    );
  }
}
