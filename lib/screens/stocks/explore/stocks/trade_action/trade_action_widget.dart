import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_expanded_tile/flutter_expanded_tile.dart';
import 'package:mynt_plus_testing/sharedWidget/no_data_found.dart';

import '../../../../../provider/stocks_provider.dart';
import '../../../../../res/res.dart';
import 'sector_themeatic_widget.dart';

class TradeAction extends StatefulWidget {
  const TradeAction({super.key});

  @override
  State<TradeAction> createState() => _TradeActionState();
}

class _TradeActionState extends State<TradeAction> {
  List<String> tradeAction = ["Top gainers", "Top losers", "Volume", "Value"];

  @override
  Widget build(BuildContext context) {
    // double screenWidth = MediaQuery.of(context).size.width;
    return Consumer(builder: (context, ScopedReader watch, _) {
      final actionTrade = watch(stocksProvide);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectorThematicWidget(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Today's trade action",
                    style:   textStyle(
                            const Color(0xff000000), 16, FontWeight.w600)),
                DropdownButtonHideUnderline(
                  child: DropdownButton2(
                    menuItemStyleData: MenuItemStyleData(
                        customHeights: actionTrade.getCustomItemsHeight()),

                    buttonStyleData: const ButtonStyleData(
                        height: 36,
                        width: 120,
                        decoration: BoxDecoration(
                            color: Color(0xffF1F3F8),
                            borderRadius:
                                BorderRadius.all(Radius.circular(32)))),
                    dropdownStyleData: DropdownStyleData(
                      width: 160,
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
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
                      actionTrade.chngTradeAct("$value");
                    },
                    // buttonHeight: 36,
                    // buttonWidth: 120,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
              height: 35,
              child: ListView.separated(
                padding: const EdgeInsets.only(left: 16.0),
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
                      child: Text(
                        tradeAction[index],
                        style: textStyle(
                            tradeAction[index] == actionTrade.tradeData
                                ? const Color(0xff000000)
                                : const Color(0xff666666),
                            14,
                            FontWeight.w600),
                      ),
                    ),
                  );
                },
                separatorBuilder: (BuildContext context, int index) {
                  return const SizedBox(width: 8);
                },
              )),
          const SizedBox(height: 12),
          actionTrade.topStockData.isNotEmpty
              ? ExpandedTileList.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  itemCount: actionTrade.topStockData.length,
                  maxOpened: 1,
                  shrinkWrap: true,
                  itemBuilder: (context, index, controller) {
                    return ExpandedTile(
                      disableAnimation: true,
                      contentseparator: 0,
                      trailingRotation: 90,
                      theme: const ExpandedTileThemeData(
                          headerColor: Color(0xffFFFFFF),
                          headerPadding:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 0),
                          //   headerSplashColor: Colors.red,
                          contentBackgroundColor: Color(0xffF1F3F8),
                          contentPadding: EdgeInsets.all(12.0),
                          //   contentRadius: 12.0,
                          trailingPadding: EdgeInsets.all(0)),
                      controller: controller,
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("${actionTrade.topStockData[index].tsym}",
                                  style: GoogleFonts.inter(
                                      textStyle: textStyle(
                                          const Color(0xff000000),
                                          14,
                                          FontWeight.w600))),
                              const SizedBox(height: 4),
                              Text("Vol :₹${actionTrade.topStockData[index].v}",
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
                              Text("₹${actionTrade.topStockData[index].lp}",
                                  style: GoogleFonts.inter(
                                      textStyle: textStyle(
                                          const Color(0xff000000),
                                          14,
                                          FontWeight.w600))),
                              const SizedBox(height: 4),
                              Text("${actionTrade.topStockData[index].pc}%",
                                  style: GoogleFonts.inter(
                                      textStyle: textStyle(
                                          actionTrade.topStockData[index].pc!
                                                  .startsWith("-")
                                              ? const Color(0xffE00000)
                                              : const Color(0xff43A833),
                                          12,
                                          FontWeight.w600))),
                            ],
                          ),
                        ],
                      ),
                      content: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              InkWell(
                                onTap: () {},
                                child: Container(
                                  decoration: const BoxDecoration(
                                      color: Color(0xffFFFFFF),
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(4))),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SvgPicture.asset(assets.charticon),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              InkWell(
                                onTap: () {},
                                child: Container(
                                  decoration: const BoxDecoration(
                                      color: Color(0xffFFFFFF),
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(4))),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SvgPicture.asset(assets.flagicon),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              InkWell(
                                onTap: () {},
                                child: Container(
                                  decoration: const BoxDecoration(
                                      color: Color(0xffFFFFFF),
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(4))),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child:
                                        SvgPicture.asset(assets.calendaricon),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              SizedBox(
                                height: 28,
                                child: ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xff43A833),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(6))),
                                  child: Text("BUY",
                                      style: GoogleFonts.inter(
                                          textStyle: textStyle(
                                              const Color(0xffFFFFFF),
                                              12,
                                              FontWeight.w600))),
                                ),
                              ),
                              const SizedBox(width: 8),
                              SizedBox(
                                height: 28,
                                child: ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(6)),
                                      backgroundColor: const Color(0xffFF1717)),
                                  child: Text("SELL",
                                      style: GoogleFonts.inter(
                                          textStyle: textStyle(
                                              const Color(0xffFFFFFF),
                                              12,
                                              FontWeight.w600))),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                      onTap: () {
                        debugPrint("tapped!!");
                      },
                      onLongTap: () {
                        debugPrint("looooooooooong tapped!!");
                      },
                    );
                  },
                )
              : const Center(child: NoDataFound()),
         const SizedBox(height: 14), ],
      );
    });
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
        textStyle:
            TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize));
  }
}
