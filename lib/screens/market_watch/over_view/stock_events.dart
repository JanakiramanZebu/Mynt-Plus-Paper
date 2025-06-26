import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart'; 

import '../../../provider/market_watch_provider.dart'; 
import '../../../provider/stocks_provider.dart';
import '../../../provider/thems.dart';
import '../../../res/global_state_text.dart';
import '../../../res/res.dart';
import '../../../sharedWidget/no_data_found.dart';

class StockEvents extends ConsumerWidget {
  const StockEvents({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final funData = ref.watch(marketWatchProvider);final theme =  ref.watch(themeProvider);
    final stockEve = ref.watch(stocksProvide);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [      
              TextWidget.heroText(
                      text:"Events" ,
                      theme: theme.isDarkMode,
                      fw: 1),	
        const SizedBox(height: 16),
        SizedBox(
            height: 36,
            child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: stockEve.eveType.length,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                            color: theme.isDarkMode
                              ? stockEve.selectedevent ==
                                      stockEve.eveType[index]
                                  ? const Color(0xffB0BEC5)
                                  : const Color(0xffB5C0CF).withOpacity(.15)
                              : stockEve.selectedevent ==
                                      stockEve.eveType[index]
                                  ? const Color(0xff000000)
                                  : const Color(0xffF1F3F8),
                        
                        borderRadius: BorderRadius.circular(98)),
                      
                      child: InkWell(
                          onTap: () async {
                            stockEve.chngEvent(stockEve.eveType[index]);
                          },
                          child: 

                                  TextWidget.subText(
                      text: stockEve.eveType[index],
                      color:  theme.isDarkMode
                                      ? stockEve.selectedevent ==
                                              stockEve.eveType[index]
                                          ? colors.colorBlack
                                          : colors.colorWhite
                                      : stockEve.selectedevent ==
                                              stockEve.eveType[index]
                                          ? colors.colorWhite
                                          : colors.colorBlack,
                      theme: theme.isDarkMode,
                      fw:  stockEve.selectedevent == stockEve.eveType[index]?  0 : 00),	
                                 
                                 
                                 ));
                },
                separatorBuilder: (BuildContext context, int index) {
                  return const SizedBox(width: 10);
                })),
        const SizedBox(height: 14),
        if (stockEve.selectedevent == "Announcement") ...[
             funData.fundamentalData!.stockEvents!.announcement!.isEmpty?const Center(child: NoDataFound()):
          ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount:
                funData.fundamentalData!.stockEvents!.announcement!.length,
            separatorBuilder: (BuildContext context, int index) {
              return Divider(color: colors.colorDivider);
            },
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                   

                             TextWidget.subText(
                      text: "Agenda",
                      color:Color(0XFF666666) ,
                      theme: theme.isDarkMode,
                      fw: 0),	
                    const SizedBox(height: 4),               

                             TextWidget.subText(
                      text:funData.fundamentalData!.stockEvents!
                            .announcement![index].agenda!
                            .substring(1) ,
                      theme: theme.isDarkMode,
                      fw: 0),	
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [   
                                 TextWidget.subText(
                      text:"Board meeting date" ,
                      textOverflow: TextOverflow.ellipsis,
                      color:Color(0XFF666666) ,
                      theme: theme.isDarkMode,
                      fw: 0),	                      

                                TextWidget.subText(
                      text:"Source date",
                      textOverflow: TextOverflow.ellipsis,
                      color:Color(0XFF666666) ,
                      theme: theme.isDarkMode,
                      fw: 0),	
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [                       

                                TextWidget.subText(
                      text: funData.fundamentalData!.stockEvents!
                                .announcement![index].boardMeetingDate! ,
                      textOverflow: TextOverflow.ellipsis,
                      theme: theme.isDarkMode,
                      fw: 0),	                      

                            TextWidget.subText(
                      text: funData.fundamentalData!.stockEvents!
                                .announcement![index].sourceDate! ,
                      textOverflow: TextOverflow.ellipsis,
                      theme: theme.isDarkMode,
                      fw: 0),	
                      ],
                    ),
                  ],
                ),
              );
            },
          )
        ] else if (stockEve.selectedevent == "Bonus") ...[
          funData.fundamentalData!.stockEvents!.bonus!.isEmpty?const Center(child: NoDataFound()):
          ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: funData.fundamentalData!.stockEvents!.bonus!.length,
            separatorBuilder: (BuildContext context, int index) {
              return Divider(color: colors.colorDivider);
            },
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                      

                                TextWidget.subText(
                      text:"Cum Bonus Date" ,
                      textOverflow: TextOverflow.ellipsis,
                      color:Color(0XFF666666) ,
                      theme: theme.isDarkMode,
                      fw: 0),	
                        

                                TextWidget.subText(
                      text:"Ex Bonus Date" ,
                      textOverflow: TextOverflow.ellipsis,
                      color:Color(0XFF666666) ,
                      theme: theme.isDarkMode,
                      fw: 0),	
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                       

                      TextWidget.subText(
                      text:funData.fundamentalData!.stockEvents!.bonus![index]
                                .cumBonusDate! ,
                      textOverflow: TextOverflow.ellipsis,
                      color:Color(0XFF666666) ,
                      theme: theme.isDarkMode,
                      fw: 0),	
                        
                              TextWidget.subText(
                      text: funData.fundamentalData!.stockEvents!.bonus![index]
                                .exBonusDate! ,
                      textOverflow: TextOverflow.ellipsis,
                      color:Color(0XFF666666) ,
                      theme: theme.isDarkMode,
                      fw: 0),	
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        
                                TextWidget.subText(
                      text:"Ratio D",
                      textOverflow: TextOverflow.ellipsis,
                      color:Color(0XFF666666) ,
                      theme: theme.isDarkMode,
                      fw: 0),	
                       

                                TextWidget.subText(
                      text:"Ratio N" ,
                      textOverflow: TextOverflow.ellipsis,
                      color:Color(0XFF666666) ,
                      theme: theme.isDarkMode,
                      fw: 0),	
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                     

                                  TextWidget.subText(
                      text:  funData.fundamentalData!.stockEvents!.bonus![index]
                                .ratioD!,
                   
					  textOverflow: TextOverflow.ellipsis,
                      theme: theme.isDarkMode,
                      fw: 0),
                       

  TextWidget.subText(
                      text:funData.fundamentalData!.stockEvents!.bonus![index]
                                .ratioN! ,
                 
					  textOverflow: TextOverflow.ellipsis,
                      theme: theme.isDarkMode,
                      fw: 0),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                       

                                TextWidget.subText(
                      text:"Record Date" ,
                      textOverflow: TextOverflow.ellipsis,
                      color:Color(0XFF666666) ,
                      theme: theme.isDarkMode,
                      fw: 0),	
                       

                                 TextWidget.subText(
                      text:"Source Date",
                      textOverflow: TextOverflow.ellipsis,
                      color:Color(0XFF666666) ,
                      theme: theme.isDarkMode,
                      fw: 0),	
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [                    

                              TextWidget.subText(
                      text:funData.fundamentalData!.stockEvents!.bonus![index]
                                .recordDate! ,                 
					  textOverflow: TextOverflow.ellipsis,
                      theme: theme.isDarkMode,
                      fw: 0),
                         TextWidget.subText(
                      text: funData.fundamentalData!.stockEvents!.bonus![index]
                                .sourceDate! ,
                 
					  textOverflow: TextOverflow.ellipsis,
                      theme: theme.isDarkMode,
                      fw: 0),
                      ],
                    ),
                  ],
                ),
              );
            },
          )
        ] else if (stockEve.selectedevent == "Divedend") ...[
             funData.fundamentalData!.stockEvents!.dividend!.isEmpty?const Center(child: NoDataFound()):
          ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: funData.fundamentalData!.stockEvents!.dividend!.length,
            separatorBuilder: (BuildContext context, int index) {
              return Divider(color: colors.colorDivider);
            },
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [                        
                                  TextWidget.subText(
                      text: "Dividend Percent",
                      color: Color(0XFF666666) ,
                      theme: theme.isDarkMode,
                      fw: 0),
                       

                                  TextWidget.subText(
                      text:"Dividend Date" ,
                      color: Color(0XFF666666),
					  textOverflow: TextOverflow.ellipsis,
                      theme: theme.isDarkMode,
                      fw: 0),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextWidget.subText(
                      text: funData.fundamentalData!.stockEvents!
                                .dividend![index].dividendPercent!,
                      textOverflow: TextOverflow.ellipsis,
                      theme: theme.isDarkMode,
                      fw: 0),
                        TextWidget.subText(
                      text: funData.fundamentalData!.stockEvents!
                                .dividend![index].dividendDate!,
                      textOverflow: TextOverflow.ellipsis,
                      theme: theme.isDarkMode,
                      fw: 0),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextWidget.subText(
                      text: "Dividend Per Share",
                      textOverflow: TextOverflow.ellipsis,
                      color: Color(0XFF666666),
                      theme: theme.isDarkMode,
                      fw: 0),
                        TextWidget.subText(
                      text: "Ex Date",
                      textOverflow: TextOverflow.ellipsis,
                      color: Color(0XFF666666),
                      theme: theme.isDarkMode,
                      fw: 0),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextWidget.subText(
                      text: funData.fundamentalData!.stockEvents!
                                .dividend![index].dividendpershare!,
                      textOverflow: TextOverflow.ellipsis,
                      theme: theme.isDarkMode,
                      fw: 0),
                        TextWidget.subText(
                      text: funData.fundamentalData!.stockEvents!
                                .dividend![index].exDate!,
                      textOverflow: TextOverflow.ellipsis,
                      theme: theme.isDarkMode,
                      fw: 0),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextWidget.subText(
                      text: "Details",
                      textOverflow: TextOverflow.ellipsis,
                      color: Color(0XFF666666),
                      theme: theme.isDarkMode,
                      fw: 0),
                        TextWidget.subText(
                      text: "Record Date",
                      textOverflow: TextOverflow.ellipsis,
                      color: Color(0XFF666666),
                      theme: theme.isDarkMode,
                      fw: 0),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextWidget.subText(
                      text: funData.fundamentalData!.stockEvents!
                                .dividend![index].details!,
                      textOverflow: TextOverflow.ellipsis,
                      theme: theme.isDarkMode,
                      fw: 0),
                        TextWidget.subText(
                      text: funData.fundamentalData!.stockEvents!
                                .dividend![index].recordDate!,
                      textOverflow: TextOverflow.ellipsis,
                      theme: theme.isDarkMode,
                      fw: 0),
                      ],
                    ),
                  ],
                ),
              );
            },
          )
        ] else if (stockEve.selectedevent == "Rights") ...[
             funData.fundamentalData!.stockEvents!.rights!.isEmpty?const Center(child: NoDataFound()):
          ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: funData.fundamentalData!.stockEvents!.rights!.length,
            separatorBuilder: (BuildContext context, int index) {
              return Divider(color: colors.colorDivider);
            },
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextWidget.subText(
                      text: "Ex Rights Date",
                      color: Color(0XFF666666),
                      theme: theme.isDarkMode,
                      fw: 0),
                        TextWidget.subText(
                      text: "Offer Price",
                      color: Color(0XFF666666),
                      theme: theme.isDarkMode,
                      fw: 0),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextWidget.subText(
                      text: funData.fundamentalData!.stockEvents!.rights![index]
                                .exRightsDate!,
                      textOverflow: TextOverflow.ellipsis,
                      theme: theme.isDarkMode,
                      fw: 0),
                        TextWidget.subText(
                      text: funData.fundamentalData!.stockEvents!.rights![index]
                                .offerPrice!,
                      textOverflow: TextOverflow.ellipsis,
                      theme: theme.isDarkMode,
                      fw: 0),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextWidget.subText(
                      text: "Premium Rs",
                      textOverflow: TextOverflow.ellipsis,
                      color: Color(0XFF666666),
                      theme: theme.isDarkMode,
                      fw: 0),
                        TextWidget.subText(
                      text: "Ration D",
                      textOverflow: TextOverflow.ellipsis,
                      color: Color(0XFF666666),
                      theme: theme.isDarkMode,
                      fw: 0),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextWidget.subText(
                      text: funData.fundamentalData!.stockEvents!.rights![index]
                                .premiumRs!,
                      textOverflow: TextOverflow.ellipsis,
                      theme: theme.isDarkMode,
                      fw: 0),
                        TextWidget.subText(
                      text: funData.fundamentalData!.stockEvents!.rights![index]
                                .rationD!,
                      textOverflow: TextOverflow.ellipsis,
                      theme: theme.isDarkMode,
                      fw: 0),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextWidget.subText(
                      text: "Ration N",
                      textOverflow: TextOverflow.ellipsis,
                      color: Color(0XFF666666),
                      theme: theme.isDarkMode,
                      fw: 0),
                        TextWidget.subText(
                      text: "Record Date",
                      textOverflow: TextOverflow.ellipsis,
                      color: Color(0XFF666666),
                      theme: theme.isDarkMode,
                      fw: 0),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextWidget.subText(
                      text: funData.fundamentalData!.stockEvents!.rights![index]
                                .ratioN!,
                      textOverflow: TextOverflow.ellipsis,
                      theme: theme.isDarkMode,
                      fw: 0),
                        TextWidget.subText(
                      text: funData.fundamentalData!.stockEvents!
                                .dividend![index].recordDate!,
                      textOverflow: TextOverflow.ellipsis,
                      theme: theme.isDarkMode,
                      fw: 0),
                      ],
                    ),
                  ],
                ),
              );
            },
          )
        ] else ...[
             funData.fundamentalData!.stockEvents!.split!.isEmpty?const Center(child: NoDataFound()):
          ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: funData.fundamentalData!.stockEvents!.split!.length,
            separatorBuilder: (BuildContext context, int index) {
              return Divider(color: colors.colorDivider);
            },
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextWidget.subText(
                      text: "Ex Date",
                      color: Color(0XFF666666),
                      theme: theme.isDarkMode,
                      fw: 0),
                        TextWidget.subText(
                      text: "Face Value Change From",
                      color: Color(0XFF666666),
                      theme: theme.isDarkMode,
                      fw: 0),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextWidget.subText(
                      text: funData.fundamentalData!.stockEvents!.split![index]
                                .exDate!,
                      textOverflow: TextOverflow.ellipsis,
                      theme: theme.isDarkMode,
                      fw: 0),
                        TextWidget.subText(
                      text: funData.fundamentalData!.stockEvents!.split![index]
                                .fvChangeFrom!,
                      textOverflow: TextOverflow.ellipsis,
                      theme: theme.isDarkMode,
                      fw: 0),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextWidget.subText(
                      text: "Face Value Change To",
                      textOverflow: TextOverflow.ellipsis,
                      color: Color(0XFF666666),
                      theme: theme.isDarkMode,
                      fw: 0),
                        TextWidget.subText(
                      text: "Record Date",
                      textOverflow: TextOverflow.ellipsis,
                      color: Color(0XFF666666),
                      theme: theme.isDarkMode,
                      fw: 0),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextWidget.subText(
                      text: funData.fundamentalData!.stockEvents!.split![index]
                                .fvChangeTo!,
                      textOverflow: TextOverflow.ellipsis,
                      theme: theme.isDarkMode,
                      fw: 0),
                        TextWidget.subText(
                      text: funData.fundamentalData!.stockEvents!.split![index]
                                .recordDate!,
                      textOverflow: TextOverflow.ellipsis,
                      theme: theme.isDarkMode,
                      fw: 0),
                      ],
                    ),
                  ],
                ),
              );
            },
          )
        ]
      ],
    );
  }
 
}
