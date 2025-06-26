import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; 
import '../../provider/market_watch_provider.dart';
import '../../provider/thems.dart';
import '../../res/global_state_text.dart';
import '../../res/res.dart';
import '../../sharedWidget/custom_drag_handler.dart';
import '../../sharedWidget/custom_exch_badge.dart';
import '../../sharedWidget/functions.dart';

class ScripDetailDialogue extends ConsumerWidget {
  const ScripDetailDialogue({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scripInfo = ref.watch(marketWatchProvider).scripInfoModel!;
    final theme = ref.watch(themeProvider);
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
          boxShadow: const [
            BoxShadow(
                color: Color(0xff999999),
                blurRadius: 4.0,
                offset: Offset(2.0, 0.0))
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const CustomDragHandler(),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 4),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                           

                                     TextWidget.titleText(
                      text: '${scripInfo.symbol} ',                  
                      theme: theme.isDarkMode,
                      fw: 1),                           

                                     TextWidget.titleText(
                      text:' ${scripInfo.option}',   
                      color: Color(0xff666666),               
                      theme: theme.isDarkMode,
                      fw: 1),

                          ],
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            CustomExchBadge(exch: "${scripInfo.exch}"),
                                     TextWidget.paraText(
                      text:"  ${scripInfo.expDate}" ,
                      color:!theme.isDarkMode
                                        ? colors.colorBlack
                                        : colors.colorWhite ,
                      theme: theme.isDarkMode,
                      fw: 1),
                          ],
                        ),
                      ]),
                  IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(
                        Icons.close_rounded,
                        color: theme.isDarkMode
                            ? const Color(0xffBDBDBD)
                            : colors.colorGrey,
                      ))
                ]),
          ),
          Divider(
              color: theme.isDarkMode
                  ? colors.darkColorDivider
                  : colors.colorDivider,
              height: 2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            width: MediaQuery.of(context).size.width,
            height: 600,
            child: ListView(
              children: [
                const SizedBox(height: 12),
                rowOfInfoData("Company Name", scripInfo.cname ?? "-",
                    "Symbol Name", scripInfo.symname ?? "-", theme),
                const SizedBox(height: 3),
                rowOfInfoData("Expiry Date", scripInfo.expDate ?? "-",
                    "Expiry Time", scripInfo.exptime ?? "-", theme),
                const SizedBox(height: 3),
                rowOfInfoData("Instrument Name", scripInfo.instname ?? "-",
                    "Segment", scripInfo.seg ?? "-", theme),
                const SizedBox(height: 3),
                rowOfInfoData("Option Type", scripInfo.optt ?? "-", "ISIN",
                    scripInfo.isin ?? "-", theme),
                const SizedBox(height: 3),
                rowOfInfoData("Tick Size", scripInfo.ti ?? "-", "Lot Size",
                    scripInfo.ls ?? "-", theme),
                const SizedBox(height: 3),
                rowOfInfoData("Price Precision", scripInfo.pp ?? "-",
                    "Multiplier", scripInfo.mult ?? "-", theme),
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
                rowOfInfoData("Gsm Ind", scripInfo.gsmind ?? "-",
                    "Elm Buy MArgin", scripInfo.elmbmrg ?? "-", theme),
                const SizedBox(height: 3),
                rowOfInfoData(
                    "Additional Long Margin",
                    scripInfo.addbmrg ?? "-",
                    "Elm Sell Margin",
                    scripInfo.elmsmrg ?? "-",
                    theme),
                const SizedBox(height: 3),
                rowOfInfoData(
                    "Additional Short Margin",
                    scripInfo.addsmrg ?? "-",
                    "Special Long Margin",
                    scripInfo.splbmrg ?? "-",
                    theme),
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
                rowOfInfoData("Var Margin", scripInfo.varmrg ?? "-",
                    "Elm Margin", scripInfo.elmmrg ?? "-", theme),
                const SizedBox(height: 3),
                rowOfInfoData("Last Trading Date", scripInfo.lastTrdD ?? "-",
                    "Strike Price", scripInfo.strprc ?? "-", theme),
                const SizedBox(height: 3),
                Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            
                                    TextWidget.paraText(
                      text:"Exposure Margin" ,
                      color:Color(0xff666666) ,
                      theme: theme.isDarkMode,
                      fw: 0),
                            const SizedBox(height: 3),                        

                                    TextWidget.subText(
                      text: scripInfo.expmrg ?? "-",
                      color:Color(0xff000000) ,
                      theme: theme.isDarkMode,
                      fw: 0),
                            const SizedBox(height: 10)
                          ]))
                    ])
              ],
            ),
          ),
        ],
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
                         TextWidget.paraText(
                      text:title1 ,
                      color:Color(0xff666666) ,
                      theme: theme.isDarkMode,
                      fw: 0),
                const SizedBox(height: 3),
                        TextWidget.subText(
                      text: value1,
                      
                      theme: theme.isDarkMode,
                      fw: 0),
                const SizedBox(height: 3),
                Divider(
                  color: theme.isDarkMode
                      ? colors.darkColorDivider
                      : colors.colorDivider,
                ),
              ])),
          const SizedBox(width: 20),
          Expanded(
              child:
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            

                TextWidget.paraText(
                      text: title2,
                      color:Color(0xff666666) ,
                      theme: theme.isDarkMode,
                      fw: 0),
            const SizedBox(height: 3),
            TextWidget.subText(
                      text: value2,
                      
                      theme: theme.isDarkMode,
                      fw: 0),
            const SizedBox(height: 3),
            Divider(
              color: theme.isDarkMode
                  ? colors.darkColorDivider
                  : colors.colorDivider,
            ),
          ]))
        ]);
  }

  
}
