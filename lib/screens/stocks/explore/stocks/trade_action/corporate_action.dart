import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart'; 
import '../../../../../provider/stocks_provider.dart';
import '../../../../../provider/thems.dart';
import '../../../../../res/res.dart';

class CorporateAction extends ConsumerWidget {
  const CorporateAction({super.key});

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final tradeAcrion =
        watch(stocksProvide).corporateActionModel!.corporateAction;
    final theme = context.read(themeProvider);
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text("Corporate Action (${tradeAcrion!.length})",
              style: textStyle(colors.colorBlack, 16, FontWeight.w600)),
          const SizedBox(height: 8),
          ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: tradeAcrion.length,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        color: theme.isDarkMode
                            ? const Color(0xffB5C0CF).withOpacity(.15)
                            : const Color(0xffF1F3F8)),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("${tradeAcrion[index].symbol}",
                                    style: textStyle(colors.colorBlack, 14,
                                        FontWeight.w500)),
                                const SizedBox(height: 4),
                                Row(children: [
                                  Text(
                                      tradeAcrion[index].biddingStartDate.toString().substring(0, 5),
                                      style: textStyle(colors.colorGrey, 14,
                                          FontWeight.w500)),
                                  Text(" to ",
                                      style: textStyle(colors.colorBlack, 12,
                                          FontWeight.w500)),
                                  Text("${tradeAcrion[index].biddingEndDate}",
                                      style: textStyle(colors.colorGrey, 14,
                                          FontWeight.w500))
                                ])
                              ]),
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("${tradeAcrion[index].issueType}",
                                    style: textStyle(
                                        colors.colorGrey, 14, FontWeight.w500)),
                                const SizedBox(height: 4),
                                Text("₹${tradeAcrion[index].maxPrice}",
                                    style: textStyle(
                                        colors.colorGrey, 14, FontWeight.w500))
                              ])
                        ]));
              },
              separatorBuilder: (BuildContext context, int index) {
                return const SizedBox(height: 8);
              })
        ]));
  }

  

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
        textStyle:
            TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize));
  }
}
