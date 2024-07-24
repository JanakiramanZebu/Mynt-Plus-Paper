import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../provider/stocks_provider.dart';

class StockMonitorScreen extends ConsumerWidget {
  const StockMonitorScreen({super.key});

  @override
  Widget build(BuildContext context,ScopedReader watch) {

    final stockMonitor=watch(stocksProvide);
    return  Padding(
      padding: const EdgeInsets.symmetric(horizontal:  16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Stock moniter", style:   textStyle(
                            const Color(0xff000000), 16, FontWeight.w600)),
                DropdownButtonHideUnderline(
                  child: DropdownButton2(
                    menuItemStyleData: MenuItemStyleData(
                        customHeights: stockMonitor.getSMCustomItemsHeight()),

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
                    hint: Text(stockMonitor.slectSMSym,
                        style: textStyle(
                            const Color(0XFF000000), 13, FontWeight.w500)),
                    items:stockMonitor.addSMDivider (),
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