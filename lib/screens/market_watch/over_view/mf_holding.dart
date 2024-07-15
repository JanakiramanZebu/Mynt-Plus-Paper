import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart'; 

import '../../../provider/market_watch_provider.dart';
import '../../../provider/thems.dart';
import '../../../res/res.dart';
import '../../../sharedWidget/no_data_found.dart';

class MutualFundholdings extends ConsumerWidget {
  const MutualFundholdings({super.key});

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final theme = context.read(themeProvider);
    final shareHoldings = watch(marketWatchProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Text("Mutual Funds Holding Trend",
            style: textStyle(
                theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                20,
                FontWeight.w600)),
        const SizedBox(height: 3),
        Text(
            "In last 3 months, mutual fund holding of the company has almost stayed constant",
            style: textStyle(const Color(0xff666666), 12, FontWeight.w500)),
        const SizedBox(height: 8),
        Container(
            padding: const EdgeInsets.only(bottom: 6),
            decoration: const BoxDecoration(
                border: Border(
                    bottom: BorderSide(color: Color(0xff999999), width: .5))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Stocks",
                    style: textStyle(
                        const Color(0xff666666), 14, FontWeight.w500)),
                DropdownButtonHideUnderline(
                    child: DropdownButton2(
                  dropdownStyleData: DropdownStyleData(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: !theme.isDarkMode
                              ? colors.colorWhite
                              : const Color.fromARGB(255, 18, 18, 18))),
                  menuItemStyleData: MenuItemStyleData(
                      customHeights: shareHoldings
                          .getCustomItemsHeight(shareHoldings.mfHoldType)),
                  buttonStyleData: ButtonStyleData(
                      height: 40,
                      width: 150,
                      decoration: BoxDecoration(
                          color: theme.isDarkMode
                              ? const Color(0xffB5C0CF).withOpacity(.15)
                              : const Color(0xffF1F3F8),
                          // border: Border.all(color: Colors.grey),
                          borderRadius: const BorderRadius.all(Radius.circular(32)))),
                  // buttonDecoration: const BoxDecoration(
                  //     color: Color(0xffF1F3F8),
                  //     // border: Border.all(color: Colors.grey),
                  //     borderRadius:
                  //         BorderRadius.all(Radius.circular(32))),
                  // buttonSplashColor: Colors.transparent,
                  isExpanded: true,
                  style: textStyle(
                      theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                      13,
                      FontWeight.w500),
                  hint: Text(shareHoldings.selctedmfHold,
                      style: textStyle(
                          theme.isDarkMode
                              ? colors.colorWhite
                              : colors.colorBlack,
                          13,
                          FontWeight.w500)),
                  items: shareHoldings
                      .addDividersAfterStock(shareHoldings.mfHoldType),
                  // customItemsHeights:
                  //     shareHoldings.getStochCustomItemsHeight(
                  //         shareHoldings.mfHoldType),
                  value: shareHoldings.selctedmfHold,
                  onChanged: (value) async {
                    shareHoldings.chngMfHold("$value");
                  },
                  // buttonHeight: 40,
                  // buttonWidth: 150
                ))
              ],
            )),
        const SizedBox(height: 10),
        shareHoldings.fundamentalData!.mFholdings!.isEmpty
            ? const Center(child: NoDataFound())
            : ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: shareHoldings.fundamentalData!.mFholdings!.length,
                separatorBuilder: (BuildContext context, int index) {
                  return Divider(color: colors.colorDivider);
                },
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: 232,
                          child: Text(
                              "${shareHoldings.fundamentalData!.mFholdings![index].mutualFund}",
                              overflow: TextOverflow.ellipsis,
                              style: textStyle(
                                  theme.isDarkMode
                                      ? colors.colorWhite
                                      : colors.colorBlack,
                                  14,
                                  FontWeight.w500)),
                        ),
                        Text(
                            shareHoldings.selctedmfHold == "AUM"
                                ? double.parse(
                                        "${shareHoldings.fundamentalData!.mFholdings![index].mfAum ?? 0.00}")
                                    .toStringAsFixed(2)
                                : "${double.parse("${shareHoldings.selctedmfHold == "Mkt cap held%" ? shareHoldings.fundamentalData!.mFholdings![index].marketCapHeld : shareHoldings.fundamentalData!.mFholdings![index].mfHoldingPercent ?? 0.00}").toStringAsFixed(2)}%",
                            style: textStyle(
                                const Color(0xff666666), 14, FontWeight.w500)),
                      ],
                    ),
                  );
                },
              )
      ],
    );
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
        textStyle:
            TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize));
  }
}
