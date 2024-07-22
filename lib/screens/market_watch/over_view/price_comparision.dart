import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';  

import '../../../models/marketwatch_model/scrip_overview/stock_data.dart';
import '../../../provider/market_watch_provider.dart';
import '../../../provider/thems.dart';
import '../../../res/res.dart';
import 'chart.dart';
import 'stock_row_data.dart';

class PriceComparision extends ConsumerWidget {
  const PriceComparision({super.key});

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final peersData = watch(marketWatchProvider);
    final theme = watch(themeProvider);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text("Peers Comparison",
          style: textStyle(
              theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
              20,
              FontWeight.w600)),
      const SizedBox(height: 5),
      Text("Peers Comparison breakdown of Refineries information",
          style: textStyle(
              theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
              12,
              FontWeight.w500)),
      Container(
        padding: const EdgeInsets.only(bottom: 6, top: 12),
        decoration: const BoxDecoration(
            border: Border(
                bottom: BorderSide(color: Color(0xff999999), width: .5))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Stocks",
                style: textStyle(const Color(0xff666666), 14, FontWeight.w500)),
            DropdownButtonHideUnderline(
                child: DropdownButton2(
              dropdownStyleData: DropdownStyleData(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: !theme.isDarkMode
                          ? colors.colorWhite
                          : const Color.fromARGB(255, 18, 18, 18))),
              menuItemStyleData: MenuItemStyleData(
                  customHeights:
                      peersData.getCustomItemsHeight(peersData.peersType)),
              buttonStyleData: ButtonStyleData(
                  height: 40,
                  width: 124,
                  decoration: BoxDecoration(
                      color: theme.isDarkMode
                          ? const Color(0xffB5C0CF).withOpacity(.15)
                          : const Color(0xffF1F3F8),
                      // border: Border.all(color: Colors.grey),
                      borderRadius: const BorderRadius.all(Radius.circular(32)))),
              // buttonDecoration: const BoxDecoration(
              //     color: Color(0xffF1F3F8),
              //     // border: Border.all(color: Colors.grey),
              //     borderRadius: BorderRadius.all(Radius.circular(32))),
              // buttonSplashColor: Colors.transparent,
              isExpanded: true,
              style: textStyle(
                  theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                  13,
                  FontWeight.w500),
              hint: Text(peersData.selctedPeers,
                  style: textStyle(
                      theme.isDarkMode ? colors.colorBlack : colors.colorBlack,
                      13,
                      FontWeight.w500)),

              items: peersData.addDividersAfterStock(peersData.peersType),
              // customItemsHeights: peersData
              //     .getStochCustomItemsHeight(peersData.peersType),
              value: peersData.selctedPeers,
              onChanged: (value) async {
                peersData.chngPeersType("$value");
              },
              // buttonHeight: 40,
              // buttonWidth: 124
            )),
          ],
        ),
      ),
      const SizedBox(height: 12),
      peersdata(peersData.fundamentalData!.peersComparison!.stock!, peersData, theme),
      Divider(color: 
      theme.isDarkMode
                  ?colors.darkColorDivider
                  :colors.colorDivider),
      peersdata(peersData.fundamentalData!.peersComparison!.peers!, peersData,theme),
      const SizedBox(height: 12),
      Divider(color: theme.isDarkMode
                  ?colors.darkColorDivider
                  :colors.colorDivider),
      const SizedBox(height: 8),
      Text("Price Comparison",
          style: textStyle(
              theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
              20,
              FontWeight.w600)),
      const SizedBox(height: 5),
      Text(
          "Compare ${peersData.getQuotes!.tsym!.replaceAll("-EQ", "")} with other stocks",
          style: textStyle(const Color(0xff000000), 12, FontWeight.w500)),
      const SizedBox(height: 14),
      const PriceComChart(),
      const SizedBox(height: 4),
      Divider(color: theme.isDarkMode
                  ?colors.darkColorDivider
                  :colors.colorDivider),
      const SizedBox(height: 4),
    ]);
  }

  ListView peersdata(List<Stock> list, MarketWatchProvider peersData ,  ThemesProvider themes) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: list.length,
      separatorBuilder: (BuildContext context, int index) {
        return Divider(color: themes.isDarkMode
                  ?colors.darkColorDivider
                  :colors.colorDivider);
      },
      itemBuilder: (BuildContext context, int index) {
        return StockRowTable(
            showIcon: false,
            title: "${list[index].sYMBOL}",
            value: peersData.selctedPeers == "LTP"
                ? "${list[index].ltp}"
                : peersData.selctedPeers == "Mkt Cap"
                    ? "${list[index].marketCap}"
                    : peersData.selctedPeers == "PE Ratio"
                        ? "${list[index].pe}"
                        : peersData.selctedPeers == "PB Ratio"
                            ? "${list[index].priceBookValue}"
                            : peersData.selctedPeers == "ROCE"
                                ? "${list[index].rocePercent}"
                                : peersData.selctedPeers == "Evebitda"
                                    ? "${list[index].evEbitda}"
                                    : peersData.selctedPeers == "Debt to EQ"
                                        ? "${list[index].debtToEquity}"
                                        : "${list[index].dividendYieldPercent}");
      },
    );
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
        textStyle:
            TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize));
  }
}
