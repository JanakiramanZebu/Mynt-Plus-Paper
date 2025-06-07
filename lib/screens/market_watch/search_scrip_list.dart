import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import '../../../provider/market_watch_provider.dart';
import '../../../res/res.dart';
import '../../locator/preference.dart';
import '../../models/marketwatch_model/search_scrip_new_model.dart';
import '../../provider/thems.dart';
import '../../routes/app_routes.dart';
import '../../sharedWidget/custom_exch_badge.dart';
import '../../sharedWidget/list_divider.dart';
import '../../sharedWidget/no_data_found.dart';

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

            return ListTile(
              onTap: () async {
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
              dense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 0,
              ),
              title: Row(
                children: [
                  Text(
                    "${scrip.symbol?.isNotEmpty == true ? scrip.symbol : scrip.tsym} ",
                    style: textStyles.scripNameTxtStyle.copyWith(
                      color: theme.isDarkMode
                          ? colors.colorWhite
                          : colors.colorBlack,
                    ),
                  ),
                  if (scrip.option != null)
                    Text(
                      "${scrip.option}",
                      style: textStyles.scripNameTxtStyle.copyWith(
                        color: const Color(0xff666666),
                      ),
                    ),
                ],
              ),
              subtitle: Row(
                children: [
                  CustomExchBadge(exch: "${scrip.exch}"),
                  if (scrip.expDate != null)
                    Text(
                      "${scrip.expDate} ",
                      style: textStyles.scripExchTxtStyle.copyWith(
                        color: theme.isDarkMode
                            ? colors.colorWhite
                            : colors.colorBlack,
                      ),
                    ),
                  if (scrip.expDate == "" && scrip.cname != null)
                    Expanded(
                      child: Text(
                        "${scrip.cname}",
                        overflow: TextOverflow.ellipsis,
                        style: textStyles.scripExchTxtStyle.copyWith(
                          color: theme.isDarkMode
                              ? colors.colorWhite
                              : colors.colorBlack,
                        ),
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
                  : IconButton(
                      splashRadius: 20,
                      onPressed: () async {
                        // Store the current page index before any operations
                        final currentIndex =
                            searchScrip.currentWatchlistPageIndex;

                        if (searchScrip.isAdded![index]) {
                          await searchScrip.isActiveAddBtn(false, index);
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

                          // Apply only the current sort preference instead of all three
                          try {
                            // Get the current sort preference
                            final currentSort =
                                ref.read(marketWatchProvider).sortByWL;

                            // Only apply sorting if there's an active preference
                            if (currentSort.isNotEmpty) {
                              await ref.read(marketWatchProvider).filterMWScrip(
                                    sorting: currentSort,
                                    wlName: widget.wlName,
                                    context: context,
                                  );
                            }

                            // Update the preference flags but don't trigger additional sorts
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

                        // Restore the page index to maintain the user's position
                        // This ensures the watchlist stays on the same page after adding/removing a scrip
                        if (currentIndex >= 0) {
                          searchScrip
                              .setCurrentWatchlistPageIndex(currentIndex);
                        }
                      },
                      icon: SvgPicture.asset(
                        searchScrip.isAdded![index]
                            ? assets.bookmarkIcon
                            : assets.bookmarkedIcon,
                        color: theme.isDarkMode && searchScrip.isAdded![index]
                            ? colors.colorLightBlue
                            : searchScrip.isAdded![index]
                                ? colors.colorBlue
                                : colors.colorGrey,
                      ),
                    ),
            );
          },
        );
      },
    );
  }
}
