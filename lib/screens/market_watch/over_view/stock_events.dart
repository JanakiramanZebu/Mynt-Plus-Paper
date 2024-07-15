import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart'; 

import '../../../provider/market_watch_provider.dart'; 
import '../../../provider/stocks_provider.dart';
import '../../../provider/thems.dart';
import '../../../res/res.dart';
import '../../../sharedWidget/no_data_found.dart';

class StockEvents extends ConsumerWidget {
  const StockEvents({super.key});

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final funData = watch(marketWatchProvider);final theme =  watch(themeProvider);
    final stockEve = watch(stocksProvide);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Events",
            style: textStyle(theme.isDarkMode?colors.colorWhite:colors.colorBlack, 20, FontWeight.w600)),
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
                           color: Color( stockEve.selectedevent == stockEve.eveType[index]
                                ?0xff000000: 0xffffffff).withOpacity(.08),
                        border: Border.all(
                            color: Color( stockEve.selectedevent == stockEve.eveType[index]
                                ? 0xff000000
                                : 0xffECEDEE)),
                        
                        borderRadius: BorderRadius.circular(98)),
                      
                      child: InkWell(
                          onTap: () async {
                            stockEve.chngEvent(stockEve.eveType[index]);
                          },
                          child: Text(stockEve.eveType[index],
                              style: textStyle(
                                  const Color(  0XFF000000),
                                  14,
                                 stockEve.selectedevent == stockEve.eveType[index]?  FontWeight.w500:FontWeight.w400))));
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
                    Text("Agenda",
                        style: textStyle(
                            const Color(0XFF666666), 14, FontWeight.w500)),
                    const SizedBox(height: 4),
                    Text(
                        funData.fundamentalData!.stockEvents!
                            .announcement![index].agenda!
                            .substring(1),
                
                        style: textStyle(
                            theme.isDarkMode?colors.colorWhite:colors.colorBlack, 14, FontWeight.w500)),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Board meeting date",
                            overflow: TextOverflow.ellipsis,
                            style: textStyle(
                                const Color(0XFF666666), 14, FontWeight.w500)),
                        Text("Source date",
                            overflow: TextOverflow.ellipsis,
                            style: textStyle(
                                const Color(0XFF666666), 14, FontWeight.w500)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                            funData.fundamentalData!.stockEvents!
                                .announcement![index].boardMeetingDate!,
                            overflow: TextOverflow.ellipsis,
                            style: textStyle(
                                theme.isDarkMode?colors.colorWhite:colors.colorBlack, 14, FontWeight.w500)),
                        Text(
                            funData.fundamentalData!.stockEvents!
                                .announcement![index].sourceDate!,
                            overflow: TextOverflow.ellipsis,
                            style: textStyle(theme.isDarkMode?colors.colorWhite:colors.colorBlack, 14, FontWeight.w500)),
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
                        Text("Cum Bonus Date",
                            style: textStyle(
                                const Color(0XFF666666), 14, FontWeight.w500)),
                        Text("Ex Bonus Date",
                            style: textStyle(
                                const Color(0XFF666666), 14, FontWeight.w500)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                            funData.fundamentalData!.stockEvents!.bonus![index]
                                .cumBonusDate!,
                            overflow: TextOverflow.ellipsis,
                            style: textStyle(
                      theme.isDarkMode?colors.colorWhite:colors.colorBlack, 14, FontWeight.w500)),
                        Text(
                            funData.fundamentalData!.stockEvents!.bonus![index]
                                .exBonusDate!,
                            overflow: TextOverflow.ellipsis,
                            style: textStyle(
                              theme.isDarkMode?colors.colorWhite:colors.colorBlack, 14, FontWeight.w500)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Ratio D",
                            overflow: TextOverflow.ellipsis,
                            style: textStyle(
                                const Color(0XFF666666), 14, FontWeight.w500)),
                        Text("Ratio N",
                            overflow: TextOverflow.ellipsis,
                            style: textStyle(
                                const Color(0XFF666666), 14, FontWeight.w500)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                            funData.fundamentalData!.stockEvents!.bonus![index]
                                .ratioD!,
                            overflow: TextOverflow.ellipsis,
                            style: textStyle(
                                theme.isDarkMode?colors.colorWhite:colors.colorBlack, 14, FontWeight.w500)),
                        Text(
                            funData.fundamentalData!.stockEvents!.bonus![index]
                                .ratioN!,
                            overflow: TextOverflow.ellipsis,
                            style: textStyle(
theme.isDarkMode?colors.colorWhite:colors.colorBlack, 14, FontWeight.w500)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Record Date",
                            overflow: TextOverflow.ellipsis,
                            style: textStyle(
                                const Color(0XFF666666), 14, FontWeight.w500)),
                        Text("Source Date",
                            overflow: TextOverflow.ellipsis,
                            style: textStyle(
                                const Color(0XFF666666), 14, FontWeight.w500)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                            funData.fundamentalData!.stockEvents!.bonus![index]
                                .recordDate!,
                            overflow: TextOverflow.ellipsis,
                            style: textStyle(
                             theme.isDarkMode?colors.colorWhite:colors.colorBlack, 14, FontWeight.w500)),
                        Text(
                            funData.fundamentalData!.stockEvents!.bonus![index]
                                .sourceDate!,
                            overflow: TextOverflow.ellipsis,
                            style: textStyle(
                       theme.isDarkMode?colors.colorWhite:colors.colorBlack,14, FontWeight.w500)),
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
                        Text("Dividend Percent",
                            style: textStyle(
                                const Color(0XFF666666), 14, FontWeight.w500)),
                        Text("Dividend Date",
                            style: textStyle(
                                const Color(0XFF666666), 14, FontWeight.w500)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                            funData.fundamentalData!.stockEvents!
                                .dividend![index].dividendPercent!,
                            overflow: TextOverflow.ellipsis,
                            style: textStyle(
                         theme.isDarkMode?colors.colorWhite:colors.colorBlack, 14, FontWeight.w500)),
                        Text(
                            funData.fundamentalData!.stockEvents!
                                .dividend![index].dividendDate!,
                            overflow: TextOverflow.ellipsis,
                            style: textStyle(
                                theme.isDarkMode?colors.colorWhite:colors.colorBlack, 14, FontWeight.w500)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Dividend Per Share",
                            overflow: TextOverflow.ellipsis,
                            style: textStyle(
                                const Color(0XFF666666), 14, FontWeight.w500)),
                        Text("Ex Date",
                            overflow: TextOverflow.ellipsis,
                            style: textStyle(
                                const Color(0XFF666666), 14, FontWeight.w500)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                            funData.fundamentalData!.stockEvents!
                                .dividend![index].dividendpershare!,
                            overflow: TextOverflow.ellipsis,
                            style: textStyle(
                         theme.isDarkMode?colors.colorWhite:colors.colorBlack, 14, FontWeight.w500)),
                        Text(
                            funData.fundamentalData!.stockEvents!
                                .dividend![index].exDate!,
                            overflow: TextOverflow.ellipsis,
                            style: textStyle(
                       theme.isDarkMode?colors.colorWhite:colors.colorBlack, 14, FontWeight.w500)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Details",
                            overflow: TextOverflow.ellipsis,
                            style: textStyle(
                                const Color(0XFF666666), 14, FontWeight.w500)),
                        Text("Record Date",
                            overflow: TextOverflow.ellipsis,
                            style: textStyle(
                                const Color(0XFF666666), 14, FontWeight.w500)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                            funData.fundamentalData!.stockEvents!
                                .dividend![index].details!,
                            overflow: TextOverflow.ellipsis,
                            style: textStyle(
                    theme.isDarkMode?colors.colorWhite:colors.colorBlack, 14, FontWeight.w500)),
                        Text(
                            funData.fundamentalData!.stockEvents!
                                .dividend![index].recordDate!,
                            overflow: TextOverflow.ellipsis,
                            style: textStyle(
                        theme.isDarkMode?colors.colorWhite:colors.colorBlack, 14, FontWeight.w500)),
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
                        Text("Ex Rights Date",
                            style: textStyle(
                                const Color(0XFF666666), 14, FontWeight.w500)),
                        Text("Offer Price",
                            style: textStyle(
                                const Color(0XFF666666), 14, FontWeight.w500)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                            funData.fundamentalData!.stockEvents!.rights![index]
                                .exRightsDate!,
                            overflow: TextOverflow.ellipsis,
                            style: textStyle(
                              theme.isDarkMode?colors.colorWhite:colors.colorBlack, 14, FontWeight.w500)),
                        Text(
                            funData.fundamentalData!.stockEvents!.rights![index]
                                .offerPrice!,
                            overflow: TextOverflow.ellipsis,
                            style: textStyle(
                          theme.isDarkMode?colors.colorWhite:colors.colorBlack, 14, FontWeight.w500)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Premium Rs",
                            overflow: TextOverflow.ellipsis,
                            style: textStyle(
                                const Color(0XFF666666), 14, FontWeight.w500)),
                        Text("Ration D",
                            overflow: TextOverflow.ellipsis,
                            style: textStyle(
                                const Color(0XFF666666), 14, FontWeight.w500)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                            funData.fundamentalData!.stockEvents!.rights![index]
                                .premiumRs!,
                            overflow: TextOverflow.ellipsis,
                            style: textStyle(
                    theme.isDarkMode?colors.colorWhite:colors.colorBlack, 14, FontWeight.w500)),
                        Text(
                            funData.fundamentalData!.stockEvents!.rights![index]
                                .rationD!,
                            overflow: TextOverflow.ellipsis,
                            style: textStyle(
                         theme.isDarkMode?colors.colorWhite:colors.colorBlack, 14, FontWeight.w500)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Ration N",
                            overflow: TextOverflow.ellipsis,
                            style: textStyle(
                                const Color(0XFF666666), 14, FontWeight.w500)),
                        Text("Record Date",
                            overflow: TextOverflow.ellipsis,
                            style: textStyle(
                                const Color(0XFF666666), 14, FontWeight.w500)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                            funData.fundamentalData!.stockEvents!.rights![index]
                                .ratioN!,
                            overflow: TextOverflow.ellipsis,
                            style: textStyle(
                          theme.isDarkMode?colors.colorWhite:colors.colorBlack, 14, FontWeight.w500)),
                        Text(
                            funData.fundamentalData!.stockEvents!
                                .dividend![index].recordDate!,
                            overflow: TextOverflow.ellipsis,
                            style: textStyle(
                            theme.isDarkMode?colors.colorWhite:colors.colorBlack, 14, FontWeight.w500)),
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
                        Text("Ex Date",
                            style: textStyle(
                                const Color(0XFF666666), 14, FontWeight.w500)),
                        Text("Face Value Change From",
                            style: textStyle(
                                const Color(0XFF666666), 14, FontWeight.w500)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                            funData.fundamentalData!.stockEvents!.split![index]
                                .exDate!,
                            overflow: TextOverflow.ellipsis,
                            style: textStyle(
                              theme.isDarkMode?colors.colorWhite:colors.colorBlack, 14, FontWeight.w500)),
                        Text(
                            funData.fundamentalData!.stockEvents!.split![index]
                                .fvChangeFrom!,
                            overflow: TextOverflow.ellipsis,
                            style: textStyle(
                            theme.isDarkMode?colors.colorWhite:colors.colorBlack, 14, FontWeight.w500)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Face Value Change To",
                            overflow: TextOverflow.ellipsis,
                            style: textStyle(
                                const Color(0XFF666666), 14, FontWeight.w500)),
                        Text("Record Date",
                            overflow: TextOverflow.ellipsis,
                            style: textStyle(
                                const Color(0XFF666666), 14, FontWeight.w500)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                            funData.fundamentalData!.stockEvents!.split![index]
                                .fvChangeTo!,
                            overflow: TextOverflow.ellipsis,
                            style: textStyle(
                  theme.isDarkMode?colors.colorWhite:colors.colorBlack, 14, FontWeight.w500)),
                        Text(
                            funData.fundamentalData!.stockEvents!.split![index]
                                .recordDate!,
                            overflow: TextOverflow.ellipsis,
                            style: textStyle(
                   theme.isDarkMode?colors.colorWhite:colors.colorBlack,14, FontWeight.w500)),
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

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
        textStyle:
            TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize));
  }
}
