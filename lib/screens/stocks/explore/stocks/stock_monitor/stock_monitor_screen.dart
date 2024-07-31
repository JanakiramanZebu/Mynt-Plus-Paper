import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart'; 

import '../../../../../provider/stocks_provider.dart';
import '../../../../../provider/thems.dart';
import '../../../../../res/res.dart';
import '../../../../../sharedWidget/list_divider.dart';
import '../../../../../sharedWidget/no_data_found.dart';

class StockMonitorScreen extends ConsumerWidget {
  const StockMonitorScreen({super.key});

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final theme = context.read(themeProvider);
    final stockMonitor = watch(stocksProvide);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Stock moniter",
                  style:
                      textStyle(const Color(0xff000000), 16, FontWeight.w600)),
              DropdownButtonHideUnderline(
                child: DropdownButton2(
                  menuItemStyleData: MenuItemStyleData(
                      customHeights: stockMonitor.getSMCustomItemsHeight()),

                  buttonStyleData: const ButtonStyleData(
                      height: 36,
                      width: 120,
                      decoration: BoxDecoration(
                          color: Color(0xffF1F3F8),
                          borderRadius: BorderRadius.all(Radius.circular(32)))),
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
                  hint: Text(stockMonitor.slectSMSym,
                      style: textStyle(
                          const Color(0XFF000000), 13, FontWeight.w500)),
                  items: stockMonitor.addSMDivider(),
                  // customItemsHeights: actionTrade.getCustomItemsHeight(),
                  value: stockMonitor.slectSMSym,
                  onChanged: (value) async {
                    stockMonitor.chngSMSym("$value");
                  },
                  // buttonHeight: 36,
                  // buttonWidth: 120,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
              height: 35,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: stockMonitor.stockMonitorFilter.length,
                itemBuilder: (BuildContext context, int index) {
                  return OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                          width: 1,
                          color: stockMonitor.stockMonitorFilter[index]
                                      ["filterType"] ==
                                  stockMonitor.slectSMFilter
                              ? const Color(0xff000000)
                              : const Color(0xff666666)),
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(40))),
                    ),
                    onPressed: () async {
                      stockMonitor.chngSMFilter(
                          stockMonitor.stockMonitorFilter[index]["filterType"],
                          stockMonitor.stockMonitorFilter[index]["cont"]);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5.0),
                      child: Text(
                        stockMonitor.stockMonitorFilter[index]["filterType"],
                        style: textStyle(
                            stockMonitor.stockMonitorFilter[index]
                                        ["filterType"] ==
                                    stockMonitor.slectSMFilter
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
         stockMonitor.stockMonitor.isEmpty?Center(child: NoDataFound()):  ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: stockMonitor.stockMonitor.length,
              itemBuilder: (BuildContext context, int idx) {

         stockMonitor.stockMonitor[idx].        chng =(double.parse(stockMonitor.stockMonitor[idx].lp??stockMonitor.stockMonitor[idx].c??"0.00")-double.parse( stockMonitor.stockMonitor[idx].c??"0.00")).toStringAsFixed(2);
                return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                    dense: true,
                    title: Text("${stockMonitor.stockMonitor[idx].tsym} ",
                        style: textStyles.scripNameTxtStyle.copyWith(
                            color: theme.isDarkMode
                                ? colors.colorWhite
                                : colors.colorBlack)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(height: 3),
                        Text("${stockMonitor.stockMonitor[idx].exch}",
                            style: textStyles.scripNameTxtStyle
                                .copyWith(color: const Color(0xff666666))),
                      ],
                    ),
                    trailing: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("₹${stockMonitor.stockMonitor[idx].lp}",
                              style: textStyle(
                                  theme.isDarkMode
                                      ? colors.colorWhite
                                      : colors.colorBlack,
                                  14,
                                  FontWeight.w600)),
                          const SizedBox(height: 4),
                          Text(
                            "${stockMonitor.stockMonitor[idx].chng} (${stockMonitor.stockMonitor[idx].pc}%)",
                            style: textStyle(
                                Color(stockMonitor.stockMonitor[idx].chng
                                        .toString()
                                        .startsWith('-')
                                    ? 0xffFF1717
                                    : stockMonitor.stockMonitor[idx].pc
                                                .toString() ==
                                            "0.00"
                                        ? 0xff999999
                                        : 0xff43A833),
                                12,
                                FontWeight.w600),
                          )
                        ]));
              },
              separatorBuilder: (BuildContext context, int index) {
                return const ListDivider();
              }),
        ],
      ),
    );
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
        textStyle:
            TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize));
  }
}
