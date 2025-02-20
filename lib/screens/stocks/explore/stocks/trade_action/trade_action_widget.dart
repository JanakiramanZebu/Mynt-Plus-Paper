import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../provider/stocks_provider.dart';
import '../../../../../res/res.dart';
import '../../../../../sharedWidget/no_data_found.dart';

class TradeAction extends StatefulWidget {
  const TradeAction({super.key});

  @override
  State<TradeAction> createState() => _TradeActionState();
}

class _TradeActionState extends State<TradeAction> {
  List<String> tradeAction = [
    "Top gainers",
    "Top losers",
    "Vol. breakout",
    "Most Active"
  ];

  @override
  Widget build(BuildContext context) {
    // double screenWidth = MediaQuery.of(context).size.width;
    return Consumer(builder: (context, ScopedReader watch, _) {
      final actionTrade = watch(stocksProvide);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // const SectorThematicWidget(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Today's trade action",
                  style: GoogleFonts.inter(
                      textStyle: textStyle(
                          const Color(0xff000000), 16, FontWeight.w600))),
              DropdownButtonHideUnderline(
                child: DropdownButton2(
                  menuItemStyleData: MenuItemStyleData(
                      customHeights: actionTrade.getCustomItemsHeight()),

                  buttonStyleData: const ButtonStyleData(
                      height: 32,
                      width: 100,
                      decoration: BoxDecoration(
                          color: Color(0xffF1F3F8),
                          borderRadius: BorderRadius.all(Radius.circular(32)))),
                  dropdownStyleData: DropdownStyleData(
                    width: 100,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    offset: const Offset(0, 8),
                  ),
                  // buttonSplashColor: Colors.transparent,
                  isExpanded: true,
                  style:
                      textStyle(const Color(0XFF000000), 13, FontWeight.w500),
                  hint: Text(actionTrade.selctedTradeAct,
                      style: textStyle(
                          const Color(0XFF000000), 13, FontWeight.w500)),
                  items: actionTrade.addDividersAfterExpDates(),
                  // customItemsHeights: actionTrade.getCustomItemsHeight(),
                  value: actionTrade.selctedTradeAct,
                  onChanged: (value) async {
                    if (value != actionTrade.selctedTradeAct) {
                      actionTrade.chngTradeAct("$value");
                    }
                  },
                  // buttonHeight: 36,
                  // buttonWidth: 120,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
              height: 35,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: tradeAction.length,
                itemBuilder: (BuildContext context, int index) {
                  return OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        width: 1,
                        color: tradeAction[index] == actionTrade.tradeData
                            ? const Color(0xff000000)
                            : const Color(0xff666666),
                      ),
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(40))),
                    ),
                    onPressed: () async {
                      actionTrade.chngTradeAction(tradeAction[index]);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5.0),
                      child: Row(
                        children: [
                          SvgPicture.asset(
                              "assets/icon/${index == 0 ? 'tg' : index == 1 ? 'tl' : index == 2 ? 'vb' : 'ma'}.svg",
                              width: 18,
                              height: 18),
                          const SizedBox(width: 6),
                          Text(
                            tradeAction[index],
                            style: textStyle(
                                tradeAction[index] == actionTrade.tradeData
                                    ? const Color(0xff000000)
                                    : const Color(0xff666666),
                                13,
                                FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                separatorBuilder: (BuildContext context, int index) {
                  return const SizedBox(width: 8);
                },
              )),
          const SizedBox(height: 16),
          actionTrade.topStockData.isNotEmpty
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: actionTrade.topStockData.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        "${actionTrade.topStockData[index].tsym}",
                                        style: GoogleFonts.inter(
                                            textStyle: textStyle(
                                                const Color(0xff000000),
                                                14,
                                                FontWeight.w600))),
                                    const SizedBox(height: 8),
                                    Text(
                                        "Vol :₹${actionTrade.topStockData[index].v}",
                                        style: GoogleFonts.inter(
                                            textStyle: textStyle(
                                                const Color(0xff999999),
                                                12,
                                                FontWeight.w500))),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                        "₹${actionTrade.topStockData[index].lp}",
                                        style: GoogleFonts.inter(
                                            textStyle: textStyle(
                                                const Color(0xff000000),
                                                14,
                                                FontWeight.w600))),
                                    const SizedBox(height: 8),
                                    Text(
                                        "${actionTrade.topStockData[index].pc}%",
                                        style: GoogleFonts.inter(
                                            textStyle: textStyle(
                                                actionTrade
                                                        .topStockData[index].pc!
                                                        .startsWith("-")
                                                    ? const Color(0xffE00000)
                                                    : const Color(0xff43A833),
                                                12,
                                                FontWeight.w600))),
                                  ],
                                ),
                              ],
                            ),
                            if (index !=
                                (actionTrade.topStockData.length - 1)) ...[
                              Divider(
                                color: colors.colorDivider,
                                thickness: 0.6,
                                height: 26,
                              ),
                            ]
                          ],
                        );
                      },
                    ),

                    // const SizedBox(height: 8,),
                    Divider(
                      color: colors.colorDivider,
                      thickness: 0.6,
                    ),
                    // InkWell(
                    //     onTap: () async {
                    //       await actionTrade.fetchALLAdindices();
                    //       Navigator.pushNamed(context, Routes.allTrade);
                    //     },
                    //     child: Text('See more stocks',
                    //         style: GoogleFonts.inter(
                    //             color: const Color(0xff0037B7),
                    //             fontSize: 14,
                    //             fontWeight: FontWeight.w600)))
                  ],
                )
              : const Center(child: NoDataFound()),
          // const SizedBox(height: 14),
        ],
      );
    });
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
        textStyle:
            TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize));
  }
}
