import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import '../../../provider/market_watch_provider.dart';
import '../../../res/res.dart';
import '../../models/marketwatch_model/search_scrip_model.dart';
import '../../provider/thems.dart';
import '../../provider/user_profile_providerNEWUI.dart';
import '../../routes/app_routes.dart';
import '../../sharedWidget/custom_exch_badge.dart';
import '../../sharedWidget/list_divider.dart';
import '../../sharedWidget/no_data_found.dart';

class SearchScripList extends ConsumerWidget {
  final List<ScripValue> searchValue;
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
        ? ListView.separated(
            shrinkWrap: true,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                onTap: () async {
                  if (wlName == "Chart||Is") {
                    await searchScrip.fetchScripQuoteIndex(
                        searchValue[index].token.toString(),
                        searchValue[index].exch.toString(),
                        context);
                    searchScrip.setChartScript(
                        searchValue[index].exch.toString(),
                        searchValue[index].token.toString(),
                        searchValue[index].tsym.toString());
                    currentRouteName = 'Chart';
                    await searchScrip.searchClear();
                    Navigator.of(context).pop();
                  } else {
                    await searchScrip.calldepthApis(
                        context, searchValue[index], isBasket);
                  }
                },
                dense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
                title: Row(
                  children: [
                    Text(
                        "${searchValue[index].symbol != null ? searchValue[index].symbol!.isEmpty ? searchValue[index].tsym : searchValue[index].symbol! : searchValue[index].tsym!} ",
                        style: textStyles.scripNameTxtStyle.copyWith(
                            color: theme.isDarkMode
                                ? colors.colorWhite
                                : colors.colorBlack)),
                    if (searchValue[index].option != null)
                      Text("${searchValue[index].option}",
                          style: textStyles.scripNameTxtStyle
                              .copyWith(color: const Color(0xff666666))),
                  ],
                ),
                subtitle: Row(
                  children: [
                    CustomExchBadge(exch: "${searchValue[index].exch}"),
                    if (searchValue[index].expDate != null)
                      Text("${searchValue[index].expDate} ",
                          style: textStyles.scripExchTxtStyle.copyWith(
                              color: theme.isDarkMode
                                  ? colors.colorWhite
                                  : colors.colorBlack)),
                    if (searchValue[index].cname != null)
                      Expanded(
                        child: Text("${searchValue[index].cname}",
                            overflow: TextOverflow.ellipsis,
                            style: textStyles.scripExchTxtStyle.copyWith(
                                color: theme.isDarkMode
                                    ? colors.colorWhite
                                    : colors.colorBlack)),
                      )
                  ],
                ),
                trailing: wlName == "Chart||Is" ||
                        wlName == "Basket" ||
                        searchScrip.isPreDefWLs == "Yes" ||
                        searchScrip.scrips.length >= 50
                    ? Container(width: .2)
                    : IconButton(
                        splashRadius: 20,
                        onPressed: () async {
                          if (searchScrip.isAdded![index]) {
                            await searchScrip.isActiveAddBtn(false, index);

                            await searchScrip.addDelMarketScrip(
                                wlName,
                                "${searchValue[index].exch}|${searchValue[index].token}",
                                context,
                                false,
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
                          color: theme.isDarkMode && searchScrip.isAdded![index]
                              ? colors.colorLightBlue
                              : searchScrip.isAdded![index]
                                  ? colors.colorBlue
                                  : colors.colorGrey,
                          searchScrip.isAdded![index]
                              ? assets.bookmarkIcon
                              : assets.bookmarkedIcon,
                        )),
              );
            },
            itemCount: searchValue.length,
            separatorBuilder: (BuildContext context, int index) {
              return const ListDivider();
            },
          )
        : const NoDataFound();
  }
}
