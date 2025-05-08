import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import '../../../provider/market_watch_provider.dart';
import '../../../res/res.dart';
import '../../models/marketwatch_model/search_scrip_new_model.dart';
import '../../provider/thems.dart';
import '../../routes/app_routes.dart';
import '../../sharedWidget/custom_exch_badge.dart';
import '../../sharedWidget/list_divider.dart';
import '../../sharedWidget/no_data_found.dart';

class SearchScripList extends ConsumerWidget {
  final List<ScripNewValue> searchValue;
  final String wlName;
  final String isBasket;
  const SearchScripList(
      {super.key,
      required this.wlName,
      required this.searchValue,
      required this.isBasket});

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final theme = context.read(themeProvider);
    final searchScrip = watch(marketWatchProvider);

    return searchValue.isNotEmpty
        ? ListView.builder(
            physics: const BouncingScrollPhysics(),
            shrinkWrap: false,
            itemBuilder: (BuildContext context, int index) {
              final itemIndex = index ~/ 2;

              bool opc = searchScrip.getOptionawait(
                  searchValue[itemIndex].exch.toString(),
                  searchValue[itemIndex].token.toString());
              if (index.isOdd) {
                return const ListDivider();
              }
              return (isBasket == "Option||Is" ? opc : true)
                  ? ListTile(
                      onTap: () async {
                        if (isBasket == "Chart||Is") {
                          await searchScrip.fetchScripQuoteIndex(
                              searchValue[itemIndex].token.toString(),
                              searchValue[itemIndex].exch.toString(),
                              context);
                          searchScrip.setChartScript(
                              searchValue[itemIndex].exch.toString(),
                              searchValue[itemIndex].token.toString(),
                              searchValue[itemIndex].tsym.toString());
                          currentRouteName = 'Chart';
                          await searchScrip.searchClear();
                          Navigator.of(context).pop();
                        } else if (isBasket == "Option||Is" && opc) {
                          currentRouteName = 'Optionchain';
                          searchScrip.setOptionScript(
                              context,
                              searchValue[itemIndex].exch.toString(),
                              searchValue[itemIndex].token.toString(),
                              searchValue[itemIndex].tsym.toString());
                          await searchScrip.searchClear();
                          Navigator.of(context).pop();
                        } else {
                          await searchScrip.calldepthApis(
                              context, searchValue[itemIndex], isBasket);
                        }
                      },
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 0),
                      title: Row(
                        children: [
                          Text(
                              "${searchValue[itemIndex].symbol != null ? searchValue[itemIndex].symbol!.isEmpty ? searchValue[itemIndex].tsym : searchValue[itemIndex].symbol! : searchValue[itemIndex].tsym!} ",
                              style: textStyles.scripNameTxtStyle.copyWith(
                                  color: theme.isDarkMode
                                      ? colors.colorWhite
                                      : colors.colorBlack)),
                          if (searchValue[itemIndex].option != null)
                            Text("${searchValue[itemIndex].option}",
                                style: textStyles.scripNameTxtStyle
                                    .copyWith(color: const Color(0xff666666))),
                        ],
                      ),
                      subtitle: Row(
                        children: [
                          CustomExchBadge(
                              exch: "${searchValue[itemIndex].exch}"),
                          if (searchValue[itemIndex].expDate != null)
                            Text("${searchValue[itemIndex].expDate} ",
                                style: textStyles.scripExchTxtStyle.copyWith(
                                    color: theme.isDarkMode
                                        ? colors.colorWhite
                                        : colors.colorBlack)),
                          if (searchValue[itemIndex].cname != null)
                            Expanded(
                              child: Text("${searchValue[itemIndex].cname}",
                                  overflow: TextOverflow.ellipsis,
                                  style: textStyles.scripExchTxtStyle.copyWith(
                                      color: theme.isDarkMode
                                          ? colors.colorWhite
                                          : colors.colorBlack)),
                            )
                        ],
                      ),
                      trailing: isBasket == "Chart||Is" ||
                              isBasket == "Option||Is" ||
                              isBasket == "Basket" ||
                              searchScrip.isPreDefWLs == "Yes" ||
                              searchScrip.scrips.length >= 50
                          ? Container(width: .2)
                          : IconButton(
                              splashRadius: 20,
                              onPressed: () async {
                                if (searchScrip.isAdded![itemIndex]) {
                                  await searchScrip.isActiveAddBtn(
                                      false, itemIndex);

                                  await searchScrip.addDelMarketScrip(
                                      wlName,
                                      "${searchValue[itemIndex].exch}|${searchValue[itemIndex].token}",
                                      context,
                                      false,
                                      false,
                                      false,
                                      false);
                                } else {
                                  await searchScrip.isActiveAddBtn(
                                      true, itemIndex);
                                  await searchScrip.addDelMarketScrip(
                                      wlName,
                                      "${searchValue[itemIndex].exch}|${searchValue[itemIndex].token}",
                                      context,
                                      true,
                                      false,
                                      false,
                                      false);
                                }
                                // await context
                                //     .read(marketWatchProvider)
                                //     .fetchAddDeleteScrip(
                                //         wlname: wlName,
                                //         context: context,
                                //         scripToken:
                                //             "${searchValue[itemIndex].exch}|${searchValue[itemIndex].token}",
                                //         isAdd: true,
                                //         isWList: false,
                                //         isSort: true);
                              },
                              icon: SvgPicture.asset(
                                color: theme.isDarkMode &&
                                        searchScrip.isAdded![itemIndex]
                                    ? colors.colorLightBlue
                                    : searchScrip.isAdded![itemIndex]
                                        ? colors.colorBlue
                                        : colors.colorGrey,
                                searchScrip.isAdded![itemIndex]
                                    ? assets.bookmarkIcon
                                    : assets.bookmarkedIcon,
                              )),
                    )
                  : Container();
            },
            itemCount: searchValue.length * 2 - 1,
            // separatorBuilder: (BuildContext context, int itemIndex) {
            //   return const ListDivider();
            // },
          )
        : const NoDataFound();
  }
}
