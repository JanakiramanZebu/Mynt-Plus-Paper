import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../provider/market_watch_provider.dart';
import '../../../provider/thems.dart';
import '../../../res/res.dart'; 
import '../../../sharedWidget/no_data_found.dart';
import 'financial.dart';
import 'price_comparision.dart';
import 'stocks_holdings_widget.dart';

class FundamentalDataWidget extends ConsumerWidget {
  const FundamentalDataWidget({super.key});

  @override
  Widget build(BuildContext context, ScopedReader watch) { final theme = context.read(themeProvider);
    final funData =
        watch(marketWatchProvider).fundamentalData!.fundamental!.isEmpty
            ? null
            : watch(marketWatchProvider).fundamentalData!.fundamental![0];
    return watch(marketWatchProvider).fundamentalData!.fundamental!.isEmpty
        ? const Center(child: NoDataFound())
        : Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 6),
                Text("Fundamental Ratios",
                    style: textStyle(
                      theme.isDarkMode?colors.colorWhite:colors.colorBlack, 20, FontWeight.w600)),
                const SizedBox(height: 5),

                Text(
                    "Fundamental breakdown of ${watch(marketWatchProvider).getQuotes!.tsym!.replaceAll("-EQ", "")} information",
                    style: textStyle(
                     theme.isDarkMode?colors.colorWhite:colors.colorBlack, 12, FontWeight.w500)),
                const SizedBox(height: 16),
                rowOfInfoData("PE RATIO", "${funData!.pe}", "SECTOR PE",
                    "${funData.sectorPe}", "EVEBITDA", "${funData.evEbitda}",theme),
                const SizedBox(height: 14),
                rowOfInfoData(
                    "PB RATIO",
                    "${funData.priceBookValue}",
                    "EPS",
                    "${funData.eps}",
                    "DIVIDEND YIELD",
                    "${funData.dividendYieldPercent}",theme),
                const SizedBox(height: 14),
                rowOfInfoData(
                    "ROCE",
                    "${funData.rocePercent}",
                    "ROE",
                    "${funData.roePercent}",
                    "DEBT TO EQUITY",
                    "${funData.debtToEquity}",theme),
                const SizedBox(height: 14),
                // if (watch(stocksProvide).moreFunRatio) ...[
                rowOfInfoData(
                    "PRICE TO SALE",
                    "${funData.salesToWorkingCapital}",
                    "BOOK VALUE",
                    "${funData.bookValue}",
                    "FACE VALUE",
                    "${funData.fv}",theme),
                // ],
                const SizedBox(height: 20),
                // Center(
                //     child: TextButton(
                //         onPressed: () {
                //           watch(stocksProvide).showMoreFunRatio();
                //         },
                //         child: Text(
                //             watch(stocksProvide).moreFunRatio
                //                 ? "Show less"
                //                 : "Show more",
                //             style:
                //                 textStyle(colors.colorBlue, 13, FontWeight.w500)))),
                const FinancialWidget(), const SizedBox(height: 4),
                const PriceComparision(),
                const SizedBox(height: 8),
                const StocksHoldingsWidget()
              ],
            ),
          );
  }

  Row rowOfInfoData(String title1, String value1, String title2, String value2,
      String title3, String value3, ThemesProvider theme) {
    return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(title1,
                    style: textStyle(
                        const Color(0xff666666), 10, FontWeight.w400)),
                const SizedBox(height: 4),
                Text(value1,
                    style: textStyle(
                        theme.isDarkMode?colors.colorWhite:colors.colorBlack, 14, FontWeight.w600)),
                const SizedBox(height: 2),
                Divider(color: 
                theme.isDarkMode
                ?colors.darkColorDivider
                :colors.colorDivider)
              ])),
          const SizedBox(width: 18),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(title2,
                    style: textStyle(
                        const Color(0xff666666), 10, FontWeight.w400)),
                const SizedBox(height: 4),
                Text(
                  value2,
                  style:
                      textStyle(theme.isDarkMode?colors.colorWhite:colors.colorBlack, 14, FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Divider(color:  theme.isDarkMode
                ?colors.darkColorDivider
                :colors.colorDivider)
              ])),
          const SizedBox(width: 18),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(title3,
                    style: textStyle(
                        const Color(0xff666666), 10, FontWeight.w400)),
                const SizedBox(height: 4),
                Text(value3,
                    style: textStyle(
                     theme.isDarkMode?colors.colorWhite:colors.colorBlack, 14, FontWeight.w600)),
                const SizedBox(height: 2),
                Divider(color:  theme.isDarkMode
                ?colors.darkColorDivider
                :colors.colorDivider)
              ]))
        ]);
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
        textStyle:
            TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize));
  }
}
