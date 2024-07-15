import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart'; 

import '../../../provider/market_watch_provider.dart';
import '../../../res/res.dart'; 
import '../../models/marketwatch_model/search_scrip_model.dart';
import '../../provider/thems.dart';
import '../../sharedWidget/custom_exch_badge.dart';
import '../../sharedWidget/list_divider.dart';
import '../../sharedWidget/no_data_found.dart'; 

class SearchScripList extends ConsumerWidget {
  final List<ScripValue> searchValue;
  final String wlName;
  const SearchScripList(
      {super.key, required this.wlName, required this.searchValue});

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final theme = context.read(themeProvider);
    final searchScrip = watch(marketWatchProvider);
    return searchValue.isNotEmpty
        ? ListView.separated(
            shrinkWrap: true,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                // onTap: wlName.isNotEmpty
                //     ? null
                //     : () async {
                //         ChartArgs chartArgs = ChartArgs(
                //             token: "${searchValue[index].token}",
                //             exch: "${searchValue[index].exch}",
                //             tsym: "${searchValue[index].tsym}");
                //         searchScrip.activeTsym(
                //             chartArgs.tsym, chartArgs.exch);
                //         await ConstantName.webViewController
                //             .evaluateJavascript(
                //                 source:
                //                     "window.tvWidget.activeChart().setSymbol('${chartArgs.exch}:${chartArgs.tsym}')");

                //         Navigator.pop(context);
                //         await searchScrip.searchClear();
                //       },
                dense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
                title: Row(
                  children: [
                    Text("${searchValue[index].symbol} ",
                        style: textStyles.scripNameTxtStyle.copyWith(
                            color: theme.isDarkMode
                                ? colors.colorWhite
                                : colors.colorBlack)),
                    Text("${searchValue[index].option}",
                        style: textStyles.scripNameTxtStyle
                            .copyWith(color: const Color(0xff666666))),
                  ],
                ),
                subtitle: Row(
                  children: [
                     CustomExchBadge(exch: "${searchValue[index].exch}"),
                    Text("${searchValue[index].expDate} ",
                        style: textStyles.scripExchTxtStyle
                            .copyWith( color: theme.isDarkMode
                                ? colors.colorWhite
                                : colors.colorBlack))
                  ],
                ),
                trailing: wlName.isEmpty
                    ? Container(width: 1)
                    : SizedBox(
                       
                      child: IconButton(
                      
                          onPressed: () async {
                            if (searchScrip.isAdded![index]) {
                              await searchScrip.isActiveAddBtn(false, index);
                      
                              await searchScrip.addDelMarketScrip(
                                  wlName,
                                  "${searchValue[index].exch}|${searchValue[index].token}",
                                  context,
                                  false,
                                  false,
                                  false);
                            } else {
                              await searchScrip.isActiveAddBtn(true, index);
                              await searchScrip.addDelMarketScrip(
                                  wlName,
                                  "${searchValue[index].exch}|${searchValue[index].token}",
                                  context,
                                  true,
                                  false,
                                  false);
                            }
                            // await context
                            //     .read(marketWatchProvider)
                            //     .fetchAddDeleteScrip(
                            //         wlname: wlName,
                            //         context: context,
                            //         scripToken:
                            //             "${searchValue[index].exch}|${searchValue[index].token}",
                            //         isAdd: true,
                            //         isWList: false,
                            //         isSort: true);
                          },
                          icon: SvgPicture.asset(
                             color:  theme.isDarkMode &&   searchScrip.isAdded![index]?colors.colorLightBlue: searchScrip.isAdded![index]?colors.colorBlue:colors.colorGrey,
                                       
                            searchScrip.isAdded![index]
                                ? assets.bookmarkIcon
                                : assets.bookmarkedIcon,
                          )),
                    ),
              );
            },
            itemCount: searchValue.length,
            separatorBuilder: (BuildContext context, int index) {
              return const ListDivider();
            },
          )
        : const NoDataFound();
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
        textStyle:
            TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize));
  }
}
