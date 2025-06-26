import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mynt_plus/sharedWidget/no_data_found.dart';
import 'package:readmore/readmore.dart';
import '../../../provider/market_watch_provider.dart';

import '../../../provider/thems.dart';
import '../../../res/global_state_text.dart';
import '../../../res/res.dart';
import 'chart.dart';
import 'mf_holding.dart';
import 'stock_events.dart';

class StocksHoldingsWidget extends ConsumerWidget {
  const StocksHoldingsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final stockHold =
        ref.watch(marketWatchProvider).fundamentalData!.shareholdings!;
    final shareHoldings = ref.watch(marketWatchProvider);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
     

               TextWidget.heroText(
                      text: "Holdings",
                   
                      theme: theme.isDarkMode,
                      fw: 1),	
      const SizedBox(height: 16),
      SizedBox(
          height: 36,
          child: shareHoldings.fundamentalData!.shareholdings!.isEmpty
              ? Center(
                  child: 
                   TextWidget.subText(
                      text: "No Holdings",
                      theme: theme.isDarkMode,
                      fw: 0),	
                )
              : ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: shareHoldings.mfHoldingDate.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                            color: theme.isDarkMode
                                ? shareHoldings.selectedMfHolddate ==
                                        shareHoldings.mfHoldingDate[index]
                                    ? const Color(0xffB0BEC5)
                                    : const Color(0xffB5C0CF).withOpacity(.15)
                                : shareHoldings.selectedMfHolddate ==
                                        shareHoldings.mfHoldingDate[index]
                                    ? const Color(0xff000000)
                                    : const Color(0xffF1F3F8),
                            borderRadius: BorderRadius.circular(98)),
                        child: InkWell(
                            onTap: () async {
                              shareHoldings.chngMfHoldDate(
                                  shareHoldings.mfHoldingDate[index], index);
                            },
                            child:                                        
                                        
                                         TextWidget.subText(
                      text: shareHoldings.mfHoldingDate[index],
                      color:  theme.isDarkMode
                                        ? shareHoldings.selectedMfHolddate ==
                                                shareHoldings
                                                    .mfHoldingDate[index]
                                            ? colors.colorBlack
                                            : colors.colorWhite
                                        : shareHoldings.selectedMfHolddate ==
                                                shareHoldings
                                                    .mfHoldingDate[index]
                                            ? colors.colorWhite
                                            : colors.colorBlack,
                      theme: theme.isDarkMode,
                      fw:  shareHoldings.selectedMfHolddate ==
                                            shareHoldings.mfHoldingDate[index]
                                        ? 0
                                        : 00),	
                                        
                                        
                                        
                                        
                                        
                                        
                                        
                                        
                                        ));
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return const SizedBox(width: 10);
                  })),
      const SizedBox(height: 16),
     

               TextWidget.titleText(
                      text:"Shareholding Breakdown" ,                
                      theme: theme.isDarkMode,
                      fw: 1),	
      const SizedBox(height: 8),
      stockHold.isEmpty
          ? Container(
              color: Color(0xff666666),
            )
          : Row(children: [
              colorBar(
                  "${stockHold[shareHoldings.selectedMfHoldindex].promoters}",
                  const Color(0xff2e8564)),
              colorBar("${stockHold[shareHoldings.selectedMfHoldindex].fiiFpi}",
                  const Color(0xff7cd36f)),
              colorBar("${stockHold[shareHoldings.selectedMfHoldindex].dii}",
                  const Color(0xfff7cd6c)),
              colorBar(
                  "${stockHold[shareHoldings.selectedMfHoldindex].retailAndOthers}",
                  const Color(0XFFfbebc4)),
              colorBar(
                  "${stockHold[shareHoldings.selectedMfHoldindex].mutualFunds}",
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
            
                 TextWidget.subText(
                      text: "Investors",
                      color: Color(0xff666666),
                      theme: theme.isDarkMode,
                      fw: 0),	
         
                 TextWidget.subText(
                      text: "Holding %",
                      color: Color(0xff666666),
                      theme: theme.isDarkMode,
                      fw: 0),
          ])),
      stockHold.isEmpty
          ? Container(
              color: Color(0xff666666),
            )
          : holdData(
              "Promoter Holding",
              "${stockHold[shareHoldings.selectedMfHoldindex].promoters}",
              const Color(0xff2e8564),
              theme),
      Divider(
          thickness: 0,
          color:
              theme.isDarkMode ? colors.darkColorDivider : colors.colorDivider,
          height: 0),
      stockHold.isEmpty
          ? Container(
              color: Color(0xff666666),
            )
          : holdData(
              "Foriegin Institution",
              "${stockHold[shareHoldings.selectedMfHoldindex].fiiFpi}",
              const Color(0xff7cd36f),
              theme),
      Divider(
          thickness: 0,
          color:
              theme.isDarkMode ? colors.darkColorDivider : colors.colorDivider,
          height: 0),
      stockHold.isEmpty
          ? Container(
              color: Color(0xff666666),
            )
          : holdData(
              "Other Domestic Institution",
              "${stockHold[shareHoldings.selectedMfHoldindex].dii}",
              const Color(0xfff7cd6c),
              theme),
      Divider(
          thickness: 0,
          color:
              theme.isDarkMode ? colors.darkColorDivider : colors.colorDivider,
          height: 0),
      stockHold.isEmpty
          ? Container(
              color: Color(0xff666666),
            )
          : holdData(
              "Retail and Others",
              "${stockHold[shareHoldings.selectedMfHoldindex].retailAndOthers}",
              const Color(0XFFfbebc4),
              theme),
      Divider(
          thickness: 0,
          color:
              theme.isDarkMode ? colors.darkColorDivider : colors.colorDivider,
          height: 0),
      stockHold.isEmpty
          ? Container(
              color: Color(0xff666666),
            )
          : holdData(
              "Mutual Funds",
              "${stockHold[shareHoldings.selectedMfHoldindex].mutualFunds}",
              const Color(0XFFdedede),
              theme),
      stockHold.isEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(child: NoDataFound()),
            )
          : Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xff999999))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                           TextWidget.titleText(
                      text:"Shareholding History" ,
                   
                      theme: theme.isDarkMode,
                      fw: 1),	
                  const SizedBox(height: 3),
                 
                           TextWidget.paraText(
                      text:"Select a segment from the breakdowns to see its pattern here" ,
                      color: Color(0xff666666),
                      theme: theme.isDarkMode,
                      fw: 0),	
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
                          customHeights: shareHoldings.getCustomItemsHeight(
                              shareHoldings.shareHoldType)),
                      buttonStyleData: ButtonStyleData(
                          height: 36,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                              color: theme.isDarkMode
                                  ? const Color(0xffB5C0CF).withOpacity(.15)
                                  : const Color(0xffF1F3F8),
                              // border: Border.all(color: Colors.grey),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(32)))),
                      // buttonDecoration: const BoxDecoration(
                      //     color: Color(0xffF1F3F8),
                      //     // border: Border.all(color: Colors.grey),
                      //     borderRadius: BorderRadius.all(Radius.circular(32))),
                      // buttonSplashColor: Colors.transparent,
                      isExpanded: true,

                      style: 
                           TextWidget.textStyle(
                 fontSize: 12 , theme: theme.isDarkMode , fw: 0 ),		
                      hint: 
                               TextWidget.paraText(
                      text: shareHoldings.selctedShareHold,
                      color:theme.isDarkMode
                                  ? colors.colorBlack
                                  : colors.colorBlack ,
                      theme: theme.isDarkMode,
                      fw: 0),	

                      items: shareHoldings.addDividersAfterExpDates(
                          shareHoldings.shareHoldType),
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
      shareHoldings.fundamentalData!.stockDescription!.isEmpty
          ? Container()
          : 

                   TextWidget.heroText(
                      text: "Stock overview",
                      theme: theme.isDarkMode,
                      fw: 1),	
      const SizedBox(height: 8),
      ReadMoreText("${shareHoldings.fundamentalData!.stockDescription}",
          style:
           TextWidget.textStyle(
                 fontSize: 12 , color: Color(0xff666666), theme: theme.isDarkMode , fw: 0 ),		
          textAlign: TextAlign.left,
          trimLines: 4,
          moreStyle: theme.isDarkMode
              ?  TextWidget.textStyle(
                 fontSize: 12 , color: colors.colorLightBlue, theme: theme.isDarkMode , fw: 0 )		
              : TextWidget.textStyle(
                 fontSize: 12 , color: colors.colorBlue, theme: theme.isDarkMode , fw: 0 )	,
          lessStyle: theme.isDarkMode
              ?  TextWidget.textStyle(
                 fontSize: 12 , color: colors.colorLightBlue, theme: theme.isDarkMode , fw: 0 )		
              : TextWidget.textStyle(
                 fontSize: 12 , color: colors.colorBlue, theme: theme.isDarkMode , fw: 0 ),
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
        title: 

                 TextWidget.subText(
                      text: name,
                      theme: theme.isDarkMode,
                      fw: 0),
        trailing: 
            
             TextWidget.subText(
                      text: "${double.parse(value == "null" ? "0.00" : value).toStringAsFixed(2)}%",
                      color: Color(0xff666666),
                      theme: theme.isDarkMode,
                      fw: 0),
            
            
            );
  }

 
}
