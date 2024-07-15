import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:readmore/readmore.dart'; 
import '../../../provider/market_watch_provider.dart';

import '../../../provider/thems.dart';
import '../../../res/res.dart';
import 'chart.dart';
import 'mf_holding.dart';
import 'stock_events.dart';

class StocksHoldingsWidget extends ConsumerWidget {
  const StocksHoldingsWidget({super.key});

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final theme = watch(themeProvider);
    final stockHold =
        watch(marketWatchProvider).fundamentalData!.shareholdings!;
    final shareHoldings = watch(marketWatchProvider);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text("Holdings",
          style: textStyle(
              theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
              20,
              FontWeight.w600)),
      const SizedBox(height: 16),
      SizedBox(
          height: 36,
          child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: shareHoldings.mfHoldingDate.length,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                        color:
                            Color(shareHoldings.selectedMfHolddate == shareHoldings.mfHoldingDate[index] ? 0xff000000 : 0xffffffff)
                                .withOpacity(.08),
                        border: Border.all(
                            color: Color(shareHoldings.selectedMfHolddate ==
                                    shareHoldings.mfHoldingDate[index]
                                ? 0xff000000
                                : 0xffECEDEE)),
                        borderRadius: BorderRadius.circular(98)),
                    child: InkWell(
                        onTap: () async {
                          shareHoldings.chngMfHoldDate(
                              shareHoldings.mfHoldingDate[index], index);
                        },
                        child: Text(shareHoldings.mfHoldingDate[index],
                            style: textStyle(
                                theme.isDarkMode
                                    ? colors.colorWhite
                                    : colors.colorBlack,
                                14,
                                shareHoldings.selectedMfHolddate ==
                                        shareHoldings.mfHoldingDate[index]
                                    ? FontWeight.w500
                                    : FontWeight.w400))));
              },
              separatorBuilder: (BuildContext context, int index) {
                return const SizedBox(width: 10);
              })),
      const SizedBox(height: 16),
      Text("Shareholding Breakdown",
          style: textStyle(
              theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
              16,
              FontWeight.w600)),
      const SizedBox(height: 8),
      Row(children: [
        colorBar("${stockHold[shareHoldings.selectedMfHoldindex].promoters}",
            const Color(0xff2e8564)),
        colorBar("${stockHold[shareHoldings.selectedMfHoldindex].fiiFpi}",
            const Color(0xff7cd36f)),
        colorBar("${stockHold[shareHoldings.selectedMfHoldindex].dii}",
            const Color(0xfff7cd6c)),
        colorBar(
            "${stockHold[shareHoldings.selectedMfHoldindex].retailAndOthers}",
            const Color(0XFFfbebc4)),
        colorBar("${stockHold[shareHoldings.selectedMfHoldindex].mutualFunds}",
            const Color(0XFFdedede))
      ]),
      const SizedBox(height: 2),
      Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: const BoxDecoration(
              border: Border(
                  bottom: BorderSide(color: Color(0xff999999), width: .5))),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text("Investors",
                style: textStyle(const Color(0xff666666), 14, FontWeight.w500)),
            Text("Holding %",
                style: textStyle(const Color(0xff666666), 14, FontWeight.w500))
          ])),
      holdData(
          "Promoter Holding",
          "${stockHold[shareHoldings.selectedMfHoldindex].promoters}",
          const Color(0xff2e8564),
          theme),
      const Divider(color: Color(0xffDDE2E7), height: 0),
      holdData(
          "Foriegin Institution",
          "${stockHold[shareHoldings.selectedMfHoldindex].fiiFpi}",
          const Color(0xff7cd36f),
          theme),
      const Divider(color: Color(0xffDDE2E7), height: 0),
      holdData(
          "Other Domestic Institution",
          "${stockHold[shareHoldings.selectedMfHoldindex].dii}",
          const Color(0xfff7cd6c),
          theme),
      const Divider(color: Color(0xffDDE2E7), height: 0),
      holdData(
          "Retail and Others",
          "${stockHold[shareHoldings.selectedMfHoldindex].retailAndOthers}",
          const Color(0XFFfbebc4),
          theme),
      const Divider(color: Color(0xffDDE2E7), height: 0),
      holdData(
          "Mutual Funds",
          "${stockHold[shareHoldings.selectedMfHoldindex].mutualFunds}",
          const Color(0XFFdedede),
          theme),
      Container(
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xff999999))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Shareholding History",
                style: textStyle(
                    theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                    16,
                    FontWeight.w600)),
            const SizedBox(height: 3),
            Text("Select a segment from the breakdowns to see its pattern here",
                style: textStyle(const Color(0xff666666), 12, FontWeight.w500)),
            const SizedBox(height: 8),
            DropdownButtonHideUnderline(
              child: DropdownButton2(
                dropdownStyleData: DropdownStyleData(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: !theme.isDarkMode
                            ? colors.colorWhite
                            : const Color.fromARGB(255, 18, 18, 18))),
                menuItemStyleData: MenuItemStyleData(
                    customHeights: shareHoldings
                        .getCustomItemsHeight(shareHoldings.finnceYears)),
                buttonStyleData: ButtonStyleData(
                    height: 36,
                    width: MediaQuery.of(context).size.width,
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
                hint: Text(shareHoldings.selctedShareHold,
                    style: textStyle(
                        theme.isDarkMode
                            ? colors.colorBlack
                            : colors.colorBlack,
                        13,
                        FontWeight.w500)),

                items: shareHoldings
                    .addDividersAfterExpDates(shareHoldings.shareHoldType),
                // customItemsHeights: shareHoldings
                //     .getCustomItemsHeight(shareHoldings.shareHoldType),
                value: shareHoldings.selctedShareHold,
                onChanged: (value) async {
                  shareHoldings.chngshareHold("$value");
                },
                // buttonHeight: 42,
                // buttonWidth: MediaQuery.of(context).size.width,
              ),
            ),
            const SizedBox(height: 8),
            const ShareHoldChart()
          ],
        ),
      ),
      const SizedBox(height: 8),
      Divider(color: colors.colorDivider),
      const SizedBox(height: 4),
      const MutualFundholdings(),
      const SizedBox(height: 10),
      Divider(color: colors.colorDivider),
      const SizedBox(height: 8),
      const StockEvents(),
      const SizedBox(height: 8),
      Divider(color: colors.colorDivider),
      const SizedBox(height: 8),
      Text("Stock overview",
          style: textStyle(
              theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
              20,
              FontWeight.w600)),
      const SizedBox(height: 8),
      ReadMoreText("${shareHoldings.fundamentalData!.stockDescription}",
          style: textStyle(const Color(0xff666666), 13, FontWeight.w500),
          textAlign: TextAlign.left,
          trimLines: 4,
          moreStyle: textStyles.morestyle,
          lessStyle: textStyles.morestyle,
          colorClickableText: const Color(0xff0037B7),
          trimMode: TrimMode.Line,
          trimCollapsedText: 'Read more',
          trimExpandedText: ' Read less'),
    ]);
  }

  Expanded colorBar(String value, Color color) {
    return Expanded(
        flex: double.parse(value == "null" ? "0.0" : value).ceil(),
        child: Container(height: 32, color: color));
  }

  ListTile holdData(
      String name, String value, Color color, ThemesProvider theme) {
    return ListTile(
        minLeadingWidth: 10,
        leading: Container(
            height: 17,
            width: 18,
            decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(3))),
        contentPadding: const EdgeInsets.symmetric(horizontal: 0),
        dense: true,
        title: Text(name,
            style: textStyle(
                theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                14,
                FontWeight.w500)),
        trailing: Text(
            "${double.parse(value == "null" ? "0.00" : value).toStringAsFixed(2)}%",
            style: textStyle(const Color(0xff666666), 14, FontWeight.w500)));
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
        textStyle:
            TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize));
  }
}
