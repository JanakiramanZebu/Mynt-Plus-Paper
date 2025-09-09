import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import '../../../provider/market_watch_provider.dart';
import '../../../res/res.dart';
import '../../locator/preference.dart';
import '../../models/marketwatch_model/search_scrip_new_model.dart';
import '../../provider/thems.dart';
import '../../res/global_state_text.dart';
import '../../routes/app_routes.dart';
import '../../sharedWidget/custom_exch_badge.dart';
import '../../sharedWidget/list_divider.dart';
import '../../sharedWidget/no_data_found.dart';
import '../../sharedWidget/snack_bar.dart';
import '../../provider/chart_provider.dart';
import '../../models/marketwatch_model/market_watch_scrip_model.dart';

class SearchScripList extends StatefulWidget {
  final List<ScripNewValue> searchValue;
  final String wlName;
  final String isBasket;
  const SearchScripList({
    super.key,
    required this.wlName,
    required this.searchValue,
    required this.isBasket,
  });

  @override
  State<SearchScripList> createState() => _searchScripList();
}

class _searchScripList extends State<SearchScripList> {
  Preferences pref = Preferences();
  late bool scripisAscending;
  late bool pricepisAscending;
  late bool perchangisAscending;

  @override
  void initState() {
    setState(() {
      scripisAscending = pref.isMWScripname ?? true;
      pricepisAscending = pref.isMWPrice ?? true;
      perchangisAscending = pref.isMWPerchang ?? true;
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final theme = ref.read(themeProvider);
        final searchScrip = ref.watch(marketWatchProvider);


        if (widget.searchValue.isEmpty) {
          return const NoDataFound();
        }

        return ListView.separated(
          physics: const BouncingScrollPhysics(),
          itemCount: widget.searchValue.length,
          separatorBuilder: (context, index) => const ListDivider(),
          itemBuilder: (BuildContext context, int index) {
            final scrip = widget.searchValue[index];
print(!searchScrip.exarr.contains('"${scrip.exch}"'));
            return Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(6),
                splashColor: theme.isDarkMode
                    ? Colors.white.withOpacity(0.15)
                    : Colors.black.withOpacity(0.15),
                highlightColor: theme.isDarkMode
                    ? Colors.white.withOpacity(0.08)
                    : Colors.black.withOpacity(0.08),
                onTap: () async {
                  searchScrip.setETF(false);
                  searchScrip.scripdepthsize(false);
                  if (widget.isBasket == "Chart||Is") {
                    await searchScrip.fetchScripQuoteIndex(
                      scrip.token.toString(),
                      scrip.exch.toString(),
                      context,
                    );
                    searchScrip.setChartScript(
                      scrip.exch.toString(),
                      scrip.token.toString(),
                      scrip.tsym.toString(),
                    );
                    
                    // Show chart overlay with the selected script
                    final chartArgs = ChartArgs(
                      tsym: scrip.tsym.toString(),
                      token: scrip.token.toString(),
                      exch: scrip.exch.toString(),
                    );
                    
                    // Preserve the previous route from the existing chart state
                    final currentChartState = ref.read(chartProvider);
                    ref.read(chartProvider.notifier).showChart(
                      chartArgs, 
                      previousRoute: currentChartState.previousRoute
                    );
                    
                    currentRouteName = 'Chart';
                    await searchScrip.searchClear();
                    Navigator.of(context).pop();
                  } else if (widget.isBasket == "Option||Is") {
                    currentRouteName = 'Optionchain';
                    searchScrip.setOptionScript(
                      context,
                      scrip.exch.toString(),
                      scrip.token.toString(),
                      scrip.tsym.toString(),
                    );
                    await searchScrip.searchClear();
                    Navigator.of(context).pop();
                  } else {
                    await searchScrip.calldepthApis(
                      context,
                      scrip,
                      widget.isBasket,
                    );
                  }
                },
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  dense: false,
                  title: Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "${scrip.symbol?.isNotEmpty == true ? scrip.symbol : scrip.tsym} ",
                          style: TextWidget.textStyle(
                            fontSize: 14,
                            theme: theme.isDarkMode,
                            color: theme.isDarkMode
                                ? colors.textPrimaryDark
                                : colors.textPrimaryLight,
                            fw: 0,
                          ),
                        ),
                        if (scrip.option != null)
                          Text(
                            "${scrip.option}",
                            style: TextWidget.textStyle(
                              fontSize: 14,
                              color: theme.isDarkMode
                                  ? colors.textPrimaryDark
                                  : colors.textPrimaryLight,
                              theme: theme.isDarkMode,
                              fw: 0,
                            ),
                          )
                      ],
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            CustomExchBadge(exch: "${scrip.exch}"),
                            if (scrip.expDate != null)
                              TextWidget.paraText(
                                text: " ${scrip.expDate}",
                                color: theme.isDarkMode
                                    ? colors.textSecondaryDark
                                    : colors.textSecondaryLight,
                                theme: theme.isDarkMode,
                                fw: 0,
                              ),
                            if (scrip.expDate == "" && scrip.cname != null)
                              Expanded(
                                child: TextWidget.paraText(
                                  text: "${scrip.cname}",
                                  textOverflow: TextOverflow.ellipsis,
                                  color: theme.isDarkMode
                                      ? colors.textSecondaryDark
                                      : colors.textSecondaryLight,
                                  theme: theme.isDarkMode,
                                  fw: 0,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  trailing: widget.isBasket == "Chart||Is" ||
                          widget.isBasket == "Option||Is" ||
                          widget.isBasket == "Basket" ||
                          searchScrip.isPreDefWLs == "Yes" ||
                          searchScrip.scrips.length >= 50
                      ? const SizedBox(width: 0.2)
                      : Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Material(
                            color: Colors.transparent,
                            shape: const CircleBorder(),
                            child: TextButton(
                              style: TextButton.styleFrom(
                                shape: const CircleBorder(),
                                padding: const EdgeInsets.all(0),
                                backgroundColor: Colors.transparent,
                                foregroundColor: Colors.transparent,
                                elevation: 0.0,
                                minimumSize: const Size(0, 40),
                                side: BorderSide.none,
                              ),
                              onPressed: () async {
                                if(!searchScrip.exarr.contains('"${scrip.exch}"')){
          error(context, "Segment is not active.");
                                }
                                else{
                                if (searchScrip.isAdded![index]) {
                                  await searchScrip.isActiveAddBtn(
                                      false, index);
                                  await searchScrip.addDelMarketScrip(
                                    widget.wlName,
                                    "${scrip.exch}|${scrip.token}",
                                    context,
                                    false,
                                    false,
                                    false,
                                    false,
                                  );
                                } else {
                                  await searchScrip.isActiveAddBtn(true, index);
                                  await searchScrip.addDelMarketScrip(
                                    widget.wlName,
                                    "${scrip.exch}|${scrip.token}",
                                    context,
                                    true,
                                    false,
                                    false,
                                    false,
                                  );

                                  try {
                                    final currentSort =
                                        ref.read(marketWatchProvider).sortByWL;

                                    if (currentSort.isNotEmpty) {
                                      await ref
                                          .read(marketWatchProvider)
                                          .filterMWScrip(
                                            sorting: currentSort,
                                            wlName: widget.wlName,
                                            context: context,
                                          );
                                    }

                                    scripisAscending = !scripisAscending;
                                    pref.setMWScrip(scripisAscending);

                                    pricepisAscending = !pricepisAscending;
                                    pref.setMWPrice(pricepisAscending);

                                    perchangisAscending = !perchangisAscending;
                                    pref.setMWPerchnage(perchangisAscending);
                                  } catch (e) {
                                    print("Error applying sort: $e");
                                  }
                                }
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(
                                    8), // ensure adequate tap target
                                child: !searchScrip.exarr.contains('"${scrip.exch}"') ?
                                SvgPicture.asset(assets.dInfo,
                                  color:  Colors.red,
                                  height: 20,
                                  width: 20,
                                ) :
                                
                                SvgPicture.asset(
                                  searchScrip.isAdded![index]
                                      ? assets.bookmarkIcon
                                      : assets.bookmarkedIcon,
                                  color:
                                  theme.isDarkMode &&
                                          searchScrip.isAdded![index]
                                      ? colors.colorLightBlue
                                      : searchScrip.isAdded![index]
                                          ? colors.colorBlue
                                          : colors.textSecondaryDark,
                                ),
                              ),
                            ),
                          ),
                        ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
