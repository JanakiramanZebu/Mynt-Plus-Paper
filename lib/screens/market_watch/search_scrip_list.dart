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
  const SearchScripList({
    super.key,
    required this.wlName,
    required this.searchValue,
    required this.isBasket,
  });

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final theme = context.read(themeProvider);
    final searchScrip = watch(marketWatchProvider);

    if (searchValue.isEmpty) {
      return const NoDataFound();
    }

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      itemCount: searchValue.length,
      separatorBuilder: (context, index) => const ListDivider(),
      itemBuilder: (BuildContext context, int index) {
        final scrip = searchValue[index];
        final bool opc = searchScrip.getOptionawait(
          scrip.exch.toString(),
          scrip.token.toString(),
        );

        if (!(isBasket == "Option||Is" ? opc : true)) {
          return const SizedBox.shrink();
        }

        return ListTile(
          onTap: () async {
            if (isBasket == "Chart||Is") {
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
            } else if (isBasket == "Option||Is" && opc) {
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
                isBasket,
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
          trailing: isBasket == "Chart||Is" ||
                  isBasket == "Option||Is" ||
                  isBasket == "Basket" ||
                  searchScrip.isPreDefWLs == "Yes" ||
                  searchScrip.scrips.length >= 50
              ? const SizedBox(width: 0.2)
              : IconButton(
                  splashRadius: 20,
                  onPressed: () async {
                    if (searchScrip.isAdded![index]) {
                      await searchScrip.isActiveAddBtn(false, index);
                      await searchScrip.addDelMarketScrip(
                        wlName,
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
                        wlName,
                        "${scrip.exch}|${scrip.token}",
                        context,
                        true,
                        false,
                        false,
                        false,
                      );
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
  }
}
