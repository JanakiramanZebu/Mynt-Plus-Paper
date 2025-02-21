import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import '../../../models/marketwatch_model/get_quotes.dart';
import '../../../provider/index_list_provider.dart';
import '../../../provider/market_watch_provider.dart';
import '../../../provider/thems.dart';
import '../../../provider/websocket_provider.dart';
import '../../../res/res.dart';
import '../../../sharedWidget/custom_drag_handler.dart';
import '../../../sharedWidget/custom_exch_badge.dart';
import '../../../sharedWidget/functions.dart';
import '../../../sharedWidget/list_divider.dart';

class IndexBottomSheet extends ConsumerWidget {
  final int defaultIndex;
  final bool src;
  const IndexBottomSheet({super.key, required this.defaultIndex, required  this.src});

  // int tabIndex = 0;
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    double widgetSize = 740;
    final double initialSize = 600.0 / MediaQuery.of(context).size.height;
    double maxSize = widgetSize / MediaQuery.of(context).size.height;
    maxSize = maxSize > 0.9 ? 0.9 : maxSize;
    bool ischeck = false;
    final theme = context.read(themeProvider);
    final indexProvide = watch(indexListProvider);
    final marketWatch = watch(marketWatchProvider);
    final socketDatas = watch(websocketProvider).socketDatas;
    return DraggableScrollableSheet(
        initialChildSize: initialSize,
        minChildSize: 0.2,
        maxChildSize: maxSize,
        expand: false,
        builder: (_, controller) {
          return Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
                boxShadow: const [
                  BoxShadow(
                      color: Color(0xff999999),
                      blurRadius: 4.0,
                      offset: Offset(2.0, 0.0))
                ]),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CustomDragHandler(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Index List",
                          style: textStyle(
                              theme.isDarkMode
                                  ? colors.colorWhite
                                  : colors.colorBlack,
                              18,
                              FontWeight.w600)),
                      Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton2(
                            dropdownStyleData: DropdownStyleData(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: !theme.isDarkMode
                                      ? colors.colorWhite
                                      : const Color.fromARGB(255, 18, 18, 18)),
                            ),
                            menuItemStyleData: MenuItemStyleData(
                                customHeights:
                                    indexProvide.getCustomItemsHeight()),
                            buttonStyleData: ButtonStyleData(
                                height: 36,
                                width: 90,
                                decoration: BoxDecoration(
                                    color: theme.isDarkMode
                                        ? const Color(0xffB5C0CF)
                                            .withOpacity(.15)
                                        : const Color(0xffF1F3F8),
                                    // border: Border.all(color: Colors.grey),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(32)))),
                            // buttonDecoration: const BoxDecoration(
                            //     color: Color(0xffF1F3F8),
                            //     // border: Border.all(color: Colors.grey),
                            //     borderRadius: BorderRadius.all(
                            //         Radius.circular(32))),
                            // buttonSplashColor: Colors.transparent,
                            isExpanded: true,
                            style: textStyle(
                                theme.isDarkMode
                                    ? colors.colorWhite
                                    : colors.colorBlack,
                                13,
                                FontWeight.w500),
                            hint: Text(indexProvide.slectedExch,
                                style: textStyle(
                                    theme.isDarkMode
                                        ? colors.colorBlack
                                        : colors.colorBlack,
                                    13,
                                    FontWeight.w500)),
                            items: indexProvide.addDividersAfterExpDates(),
                            // customItemsHeights:
                            //     indexProvide.getCustomItemsHeight(),
                            value: indexProvide.slectedExch,
                            onChanged: (value) async {
                              indexProvide.fetchIndexList("$value", context);
                            },
                            // buttonHeight: 36,
                            // buttonWidth: 90,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(
                    color: theme.isDarkMode
                        ? colors.darkColorDivider
                        : colors.colorDivider),
                Expanded(
                  child: indexProvide.isLoad
                      ? const Center(child: CircularProgressIndicator())
                      : indexProvide.indValuesList.isNotEmpty
                          ? ListView.builder(
                              shrinkWrap: false,
                              controller: controller,
                              physics: const BouncingScrollPhysics(
                                  parent: AlwaysScrollableScrollPhysics()),
                              itemCount:
                                  indexProvide.indValuesList.length * 2 - 1,
                              itemBuilder: (BuildContext context, idx) {
                                int index = idx ~/ 2;

                                if (indexProvide.defaultIndexList!.indValues![0]
                                            .token ==
                                        indexProvide
                                            .indValuesList[index].token ||
                                    indexProvide.defaultIndexList!.indValues![1]
                                            .token ==
                                        indexProvide
                                            .indValuesList[index].token ||
                                    indexProvide.defaultIndexList!.indValues![2]
                                            .token ==
                                        indexProvide
                                            .indValuesList[index].token ||
                                    indexProvide.defaultIndexList!.indValues![3]
                                            .token ==
                                        indexProvide
                                            .indValuesList[index].token) {
                                  ischeck = true;
                                } else {
                                  ischeck = false;
                                }
                                String ltp = '0';
                                String ch = '0.00';
                                String chp = '0.00';
                                socketDatas.containsKey(
                                    indexProvide.indValuesList[index].token);
                                if (socketDatas.isNotEmpty) {
                                  final raw = indexProvide.indValuesList[index];

                                  if (socketDatas.containsKey(raw.token)) {
                                    ltp =
                                        socketDatas[raw.token]['lp'].toString();
                                    ch = socketDatas[raw.token]['chng']
                                        .toString();
                                    chp =
                                        socketDatas[raw.token]['pc'].toString();
                                  }
                                }
                                // DepthInputArgs depthArgs = DepthInputArgs(
                                //     exch: indexProvide
                                //         .indValuesList[index].exch
                                //         .toString(),
                                //     token: indexProvide
                                //         .indValuesList[index].token
                                //         .toString(),
                                //     tsym: indexProvide
                                //         .indValuesList[index].idxname
                                //         .toString().toUpperCase(),
                                //     instname: indexProvide
                                //         .indValuesList[index].tsym
                                //         .toString(),
                                //     symbol: indexProvide
                                //         .indValuesList[index].tsym
                                //         .toString(),
                                //     expDate: '',
                                //     option: '');
                                // Navigator.pop(context);
                                // await marketWatch.calldepthApis(
                                //     context, depthArgs);
                                if (idx.isOdd) {
                                  return const ListDivider();
                                }
                                return InkWell(
                                  onTap: () async {
                                    await marketWatch.fetchScripQuoteIndex(
                                        indexProvide.indValuesList[index].token
                                            .toString(),
                                        indexProvide.slectedExch.toString(),
                                        context);

                                    final quots = marketWatch.getQuotes;
                                    DepthInputArgs depthArgs = DepthInputArgs(
                                        exch: quots!.exch.toString(),
                                        token: quots.token.toString(),
                                        tsym: quots.tsym.toString(),
                                        instname: quots.instname.toString(),
                                        symbol: quots.symbol.toString(),
                                        expDate: quots.expDate.toString(),
                                        option: quots.option.toString());
                                    Navigator.pop(context);
                                    await marketWatch.calldepthApis(
                                        context, depthArgs);
                                  },
                                  child: ListTile(
                                    contentPadding:  EdgeInsets.only(
                                        left: 14, right:  src ? 14 :4),
                                    dense: true,
                                    title: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                            indexProvide
                                                .indValuesList[index].idxname!
                                                .toUpperCase(),
                                            style: textStyles.scripNameTxtStyle
                                                .copyWith(
                                                    color: theme.isDarkMode
                                                        ? colors.colorWhite
                                                        : colors.colorBlack)),
                                        Text("₹$ltp",
                                            style: textStyle(
                                                theme.isDarkMode
                                                    ? colors.colorWhite
                                                    : colors.colorBlack,
                                                14,
                                                FontWeight.w600)),
                                      ],
                                    ),
                                    subtitle: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          CustomExchBadge(
                                              exch: indexProvide.slectedExch),
                                          Text(
                                            "${ch == "null" ? 0.00 : ch} (${chp == "null" ? 0.00 : chp}%)",
                                            style: textStyle(
                                                ch.toString().startsWith("-") ||
                                                        chp
                                                            .toString()
                                                            .startsWith('-')
                                                    ? colors.darkred
                                                    : (ch.toString() ==
                                                                    "null" ||
                                                                chp.toString() ==
                                                                    "null") ||
                                                            (ch.toString() ==
                                                                    "0.00" ||
                                                                chp.toString() ==
                                                                    "0.00")
                                                        ? colors.ltpgrey
                                                        : colors.ltpgreen,
                                                12,
                                                FontWeight.w600),
                                          )
                                        ]),
                                    trailing: src ? null : IconButton(
                                        onPressed: () async {
                                          if (indexProvide.defaultIndexList!
                                                      .indValues![0].token ==
                                                  indexProvide
                                                      .indValuesList[index]
                                                      .token ||
                                              indexProvide.defaultIndexList!
                                                      .indValues![1].token ==
                                                  indexProvide
                                                      .indValuesList[index]
                                                      .token ||
                                              indexProvide.defaultIndexList!
                                                      .indValues![2].token ==
                                                  indexProvide
                                                      .indValuesList[index]
                                                      .token ||
                                              indexProvide.defaultIndexList!
                                                      .indValues![3].token ==
                                                  indexProvide
                                                      .indValuesList[index]
                                                      .token) {
                                            Fluttertoast.showToast(
                                                msg: "Scrip Already Exist!!",
                                                backgroundColor: Colors.amber);
                                          } else {
                                            await indexProvide.changeIndex(
                                                indexProvide
                                                    .indValuesList[index],
                                                context,
                                                defaultIndex);

                                            Navigator.of(context).pop();
                                          }
                                        },
                                        icon: SvgPicture.asset(
                                          color: theme.isDarkMode && ischeck
                                              ? colors.colorLightBlue
                                              : ischeck
                                                  ? colors.colorBlue
                                                  : colors.colorGrey,
                                          ischeck
                                              ? assets.bookmarkIcon
                                              : assets.bookmarkedIcon,
                                        )),
                                  ),
                                );
                              })
                          : Center(
                              child: Text("No Data found",
                                  style: textStyle(const Color(0xff777777), 15,
                                      FontWeight.w500)),
                            ),
                )
              ],
            ),
          );
        });
  }
}
