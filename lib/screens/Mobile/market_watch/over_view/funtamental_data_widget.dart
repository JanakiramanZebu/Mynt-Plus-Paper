import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../provider/market_watch_provider.dart';
import '../../../../provider/thems.dart';
import '../../../../res/global_state_text.dart';
import '../../../../res/res.dart';
import '../../../../sharedWidget/no_data_found.dart';
import 'financial.dart';
import 'price_comparision.dart';
import 'stocks_holdings_widget.dart';

class FundamentalDataWidget extends ConsumerWidget {
  const FundamentalDataWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.read(themeProvider);
    
    // Get fundamental data - using more focused approach instead of watching entire provider
    final marketWatchProv = ref.watch(marketWatchProvider);
    final fundamentalData = marketWatchProv.fundamentalData;
    final tsym = marketWatchProv.getQuotes?.tsym;
    
    if (fundamentalData?.fundamental?.isEmpty ?? true) {
      return const Center(child: NoDataFound());
    }
    
    // Cache the fundamental data to avoid repeated access
    final funData = fundamentalData!.fundamental![0];
    final symbolName = tsym?.replaceAll("-EQ", "") ?? "";
    
    return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 6),
          _FundamentalHeader(theme: theme, symbolName: symbolName),
          const SizedBox(height: 16),
          _FundamentalRatiosSection(funData: funData, theme: theme),
          // These widgets are optimized internally
          const FinancialWidget(), 
          const SizedBox(height: 4),
          const PriceComparision(),
          const SizedBox(height: 8),
          const StocksHoldingsWidget()
        ],
      ),
    );
  }

  // Extracted static method to avoid recreating text style
 
}

// Extracted header section to avoid rebuilding when data doesn't change
class _FundamentalHeader extends StatelessWidget {
  final ThemesProvider theme;
  final String symbolName;

  const _FundamentalHeader({required this.theme, required this.symbolName});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [    
         TextWidget.heroText(
                      text:  "Fundamental Ratios",
                    
                      theme: theme.isDarkMode,
                      fw: 1),
                const SizedBox(height: 5),   
         TextWidget.paraText(
                      text:  "Fundamental breakdown of $symbolName information" ,
                   
                      theme: theme.isDarkMode,
                      fw: 0),
      ],
    );
  }
}

// Extracted ratios section to avoid rebuilding when other parts change
class _FundamentalRatiosSection extends StatelessWidget {
  final dynamic funData;
  final ThemesProvider theme;

  const _FundamentalRatiosSection({required this.funData, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _rowOfInfoData(
                    "PE RATIO",
            "${funData.pe}",
                    "SECTOR PE",
                    "${funData.sectorPe}",
                    "EVEBITDA",
                    "${funData.evEbitda}",
                    theme),
                const SizedBox(height: 14),
        _rowOfInfoData(
                    "PB RATIO",
                    "${funData.priceBookValue}",
                    "EPS",
                    "${funData.eps}",
                    "DIVIDEND YIELD",
                    "${funData.dividendYieldPercent}",
                    theme),
                const SizedBox(height: 14),
        _rowOfInfoData(
                    "ROCE",
                    "${funData.rocePercent}",
                    "ROE",
                    "${funData.roePercent}",
                    "DEBT TO EQUITY",
                    "${funData.debtToEquity}",
                    theme),
                const SizedBox(height: 14),
        _rowOfInfoData(
                    "PRICE TO SALE",
                    "${funData.salesToWorkingCapital}",
                    "BOOK VALUE",
                    "${funData.bookValue}",
                    "FACE VALUE",
                    "${funData.fv}",
                    theme),
                const SizedBox(height: 20),
              ],
          );
  }

  Row _rowOfInfoData(String title1, String value1, String title2, String value2,
      String title3, String value3, ThemesProvider theme) {
    return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [  
                         TextWidget.captionText(
                      text:title1 ,
                      color:Color(0xff666666) ,
                      theme: theme.isDarkMode,
                      fw: 00),
                const SizedBox(height: 4),
                         TextWidget.subText(
                      text:value1 ,
                   
                      theme: theme.isDarkMode,
                      fw: 1),
                const SizedBox(height: 2),
                Divider(
                    color: theme.isDarkMode
                        ? colors.darkColorDivider
                        : colors.colorDivider)
              ])),
          const SizedBox(width: 18),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [  
                         TextWidget.captionText(
                      text: title2,
                      color: Color(0xff666666),
                      theme: theme.isDarkMode,
                      fw: 00),
                const SizedBox(height: 4),               
                 TextWidget.subText(
                      text: value2,                
                      theme: theme.isDarkMode,
                      fw: 1),
                const SizedBox(height: 2),
                Divider(
                    color: theme.isDarkMode
                        ? colors.darkColorDivider
                        : colors.colorDivider)
              ])),
          const SizedBox(width: 18),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                        TextWidget.captionText(
                      text:title3 ,
                      color:Color(0xff666666) ,
                      theme: theme.isDarkMode,
                      fw: 00),
                const SizedBox(height: 4),
               
                        TextWidget.subText(
                      text:value3 ,
                     
                      theme: theme.isDarkMode,
                      fw: 1),
                const SizedBox(height: 2),
                Divider(
                    color: theme.isDarkMode
                        ? colors.darkColorDivider
                        : colors.colorDivider)
              ]))
        ]);
  }
}
