import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart'; 

import '../../provider/market_watch_provider.dart';
import '../../provider/thems.dart';
import '../../res/res.dart';
import '../../sharedWidget/custom_exch_badge.dart'; 

class ScripDetailDialogue extends ConsumerWidget {
  const ScripDetailDialogue({super.key});

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final scripInfo = watch(marketWatchProvider).scripInfoModel!;
    final theme = watch(themeProvider);
    return AlertDialog(
      backgroundColor: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10))),
      scrollable: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      titlePadding: const EdgeInsets.all(0),
      title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 8, right: 4),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text('${scripInfo.symbol} ',
                                  style: textStyle(
                                      theme.isDarkMode
                                          ? colors.colorWhite
                                          : colors.colorBlack,
                                      16,
                                      FontWeight.w600)),Text(' ${scripInfo.option}',
                              style: textStyle(const Color(0xff666666), 16,
                                  FontWeight.w600)),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              CustomExchBadge(exch: "${scripInfo.exch}"), Text("  ${scripInfo.expDate}",
                                                style: textStyle(
                                             !theme.isDarkMode
                                                      ? colors.colorBlack
                                                      : colors.colorWhite,
                                                    12,
                                                    FontWeight.w600)),
                            ],
                          ),
                        ]),
                    IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.close_rounded))
                  ]),
            ),
            Divider(color: colors.colorDivider, height: 2)
          ]),
      content: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: 600,
        child: ListView(
          children: [
            const SizedBox(height: 12),
            rowOfInfoData("Company Name", scripInfo.cname ?? "-", "Symbol Name",
                scripInfo.symname ?? "-", theme),
            const SizedBox(height: 3),
            rowOfInfoData("Segment", scripInfo.seg ?? "-", "Expiry Date",
                scripInfo.expDate ?? "-", theme),
            const SizedBox(height: 3),
            rowOfInfoData("Instrument Name", scripInfo.instname ?? "-",
                "Strike Price", scripInfo.strprc ?? "-", theme),
            const SizedBox(height: 3),
            rowOfInfoData("Option Type", scripInfo.optt ?? "-", "ISIN",
                scripInfo.isin ?? "-", theme),
            const SizedBox(height: 3),
            rowOfInfoData("Tick Size", scripInfo.ti ?? "-", "Lot Size",
                scripInfo.ls ?? "-", theme),
            const SizedBox(height: 3),
            rowOfInfoData("Price Precision", scripInfo.pp ?? "-", "Multiplier",
                scripInfo.mult ?? "-", theme),
            const SizedBox(height: 3),
            rowOfInfoData("Gn/Gd * Pn/Pd", scripInfo.prcftrD ?? "-",
                "Price Units", scripInfo.prcunt ?? "-", theme),
            const SizedBox(height: 3),
            rowOfInfoData("Price Quote Qty", scripInfo.prcqqty ?? "-",
                "Trade Units", scripInfo.trdunt ?? "-", theme),
            const SizedBox(height: 3),
            rowOfInfoData("Delivery Units", scripInfo.delunt ?? "-",
                "Freeze Qty", scripInfo.frzqty ?? "-", theme),
            const SizedBox(height: 3),
            rowOfInfoData("Gsm Ind", scripInfo.gsmind ?? "-", "Elm Buy MArgin",
                scripInfo.elmbmrg ?? "-", theme),
            const SizedBox(height: 3),
            rowOfInfoData("Additional Long Margin", scripInfo.addbmrg ?? "-",
                "Elm Sell Margin", scripInfo.elmsmrg ?? "-", theme),
            const SizedBox(height: 3),
            rowOfInfoData("Additional Short Margin", scripInfo.addsmrg ?? "-",
                "Special Long Margin", scripInfo.splbmrg ?? "-", theme),
            const SizedBox(height: 3),
            rowOfInfoData("Delivery Margin", scripInfo.delmrg ?? "-",
                "Special Short Margin", scripInfo.splsmrg ?? "-", theme),
            const SizedBox(height: 3),
            rowOfInfoData("Tender Margin", scripInfo.tenmrg ?? "-",
                "Tender Start Date", scripInfo.tenstrd ?? "-", theme),
            const SizedBox(height: 3),
            rowOfInfoData("Exercise Start Date", scripInfo.exestrd ?? "-",
                "Tender End Date", scripInfo.tenendd ?? "-", theme),
            const SizedBox(height: 3),
            rowOfInfoData("Exercise End Date", scripInfo.exeendd ?? "-",
                "Contract Token", scripInfo.token ?? "-", theme),
            const SizedBox(height: 3),
            rowOfInfoData("Var Margin", scripInfo.varmrg ?? "-", "Elm Margin",
                scripInfo.elmmrg ?? "-", theme),
            const SizedBox(height: 3),
            const SizedBox(height: 3),
            Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text("Exposure Margin",
                            style: textStyle(
                                const Color(0xff666666), 12, FontWeight.w500)),
                        const SizedBox(height: 3),
                        Text(scripInfo.expmrg ?? "-",
                            style: textStyle(
                                const Color(0xff000000), 14, FontWeight.w500)),
                        const SizedBox(height: 10)
                      ]))
                ])
          ],
        ),
      ),
    );
  }

  Row rowOfInfoData(String title1, String value1, String title2, String value2,
      ThemesProvider theme) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(title1,
                    style: textStyle(
                        const Color(0xff666666), 12, FontWeight.w500)),
                const SizedBox(height: 3),
                Text(value1,
                    style: textStyle(
                        theme.isDarkMode
                            ? colors.colorWhite
                            : colors.colorBlack,
                        14,
                        FontWeight.w500)),
                const SizedBox(height: 3),
                Divider(color: colors.colorDivider)
              ])),
          const SizedBox(width: 20),
          Expanded(
              child:
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(title2,
                style: textStyle(const Color(0xff666666), 12, FontWeight.w500)),
            const SizedBox(height: 3),
            Text(
              value2,
              style: textStyle(
                  theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                  14,
                  FontWeight.w500),
            ),
            const SizedBox(height: 3),
            Divider(color: colors.colorDivider)
          ]))
        ]);
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
        textStyle:
            TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize));
  }
}
