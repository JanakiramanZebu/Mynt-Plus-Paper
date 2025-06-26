import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/order_book_model/gtt_order_book.dart';
import '../../provider/market_watch_provider.dart';
import '../../provider/order_provider.dart';
import '../../provider/thems.dart';
import '../../provider/websocket_provider.dart';
import '../../res/global_state_text.dart';
import '../../res/res.dart';
import '../../routes/route_names.dart';
import '../../sharedWidget/custom_back_btn.dart';
import '../../sharedWidget/custom_exch_badge.dart';
import '../../sharedWidget/scrip_info_btns.dart';

class GttOrderDetail extends ConsumerWidget {
  final GttOrderBookModel gttOrderBook;
  const GttOrderDetail({super.key, required this.gttOrderBook});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scripInfo = ref.watch(marketWatchProvider);
    final theme = ref.read(themeProvider);

    return StreamBuilder<Map>(
      stream: ref.watch(websocketProvider).socketDataStream,
      builder: (context, snapshot) {
        final socketDatas = snapshot.data ?? {};

        // Update model with real-time data if available
        GttOrderBookModel displayData = gttOrderBook;
        if (socketDatas.containsKey(displayData.token)) {
          final socketData = socketDatas[displayData.token];

          // Only update with valid values
          final lp = socketData['lp']?.toString();
          if (lp != null && lp != "null" && lp != "0") {
            displayData.ltp = lp;
          }

          final pc = socketData['pc']?.toString();
          if (pc != null && pc != "null") {
            displayData.perChange = pc;
          }

          final chng = socketData['chng']?.toString();
          if (chng != null && chng != "null") {
            displayData.change = chng;
          }
        }

        return Scaffold(
            appBar: AppBar(
                elevation: .2,
                leadingWidth: 41,
                centerTitle: false,
                titleSpacing: 6,
                leading: const CustomBackBtn(),
                shadowColor: const Color(0xffECEFF3),
                title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              TextWidget.titleText(text: "${displayData.symbol}",theme:theme.isDarkMode,fw: 1),
                              TextWidget.subText(text: " ${displayData.option} ",theme: false,color: theme.isDarkMode
                                          ? colors.colorWhite
                                          : colors.colorBlack,fw: 0,textOverflow: TextOverflow.ellipsis),
                            ],
                          ),
                          TextWidget.titleText(text: "₹${displayData.ltp??'0.00'}",theme:theme.isDarkMode,fw: 1),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(children: [
                              CustomExchBadge(exch: "${displayData.exch}"),
                              TextWidget.paraText(text: "  ${displayData.expDate}",theme:theme.isDarkMode,fw: 1),
                            ]),
                            TextWidget.paraText(text: "${double.parse("${displayData.change ?? 0.00} ").toStringAsFixed(2)} (${displayData.perChange ?? 0.00}%)",theme: false, color:(displayData.change == "null" ||
                                                displayData.change == null) ||
                                            displayData.change == "0.00"
                                        ? colors.ltpgrey
                                        : displayData.change!.startsWith("-") ||
                                                displayData.perChange!
                                                    .startsWith("-")
                                            ? colors.darkred
                                            : colors.ltpgreen ,fw: 0),
                          ])
                    ])),
            body: ListView(
              children: [
                ScripInfoBtns(
                    exch: '${displayData.exch}',
                    token: '${displayData.token}',
                    insName: '',
                    tsym: '${displayData.tsym}'),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if(displayData.placeOrderParams != null)
                      TextWidget.titleText(text: "${ displayData.placeOrderParams?.trantype == 'B' ? 'Buy' : 'Sell'} Trigger @ ${displayData.oivariable?.first.d}",theme: theme.isDarkMode,fw: 1),
                      const SizedBox(height: 16),
                      rowOfInfoData(
                          "Product",
                          displayData.placeOrderParams?.prd == "C" ? "CNC" : "MIS",
                          "Order Type",
                          "${displayData.placeOrderParams?.prctyp}",
                          theme),
                      const SizedBox(height: 4),
                      rowOfInfoData( "Qty", "${displayData.placeOrderParams?.qty}",
                        "Price", "${displayData.placeOrderParams?.prctyp=="MKT"? "MKT":displayData.placeOrderParams?.prc}", theme),
                      const SizedBox(height: 4),
                    ],
                  ),
                ),
                
                if(displayData.placeOrderParamsLeg2 != null) 
                 Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextWidget.titleText(text: "${ displayData.placeOrderParamsLeg2?.trantype == 'B' ? 'Buy' : 'Sell'} Trigger @ ${displayData.oivariable?.last.d}",theme: theme.isDarkMode,fw: 1),
                      const SizedBox(height: 16),
                      rowOfInfoData(
                         "Product",
                          displayData.placeOrderParamsLeg2?.prd == "C" ? "CNC" : "MIS",
                          "Order Type",
                          "${displayData.placeOrderParamsLeg2?.prctyp}",
                          theme), 
                      const SizedBox(height: 4),
                      rowOfInfoData("Qty", "${displayData.placeOrderParamsLeg2?.qty}",
                       "Price", "${displayData.placeOrderParamsLeg2?.prctyp=="MKT"? "MKT":displayData.placeOrderParamsLeg2?.prc}", theme),
                    ],
                  ),
                ),
                if(displayData.remarks != null && displayData.remarks != "")
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextWidget.titleText(text: "Remarks",theme: theme.isDarkMode,fw: 1),
                      const SizedBox(height: 16),
                      TextWidget.subText(text: "${displayData.remarks}",theme:theme.isDarkMode ,fw: 0),                    
                    ],
                  ),
                ),
               ],
            ),
            bottomNavigationBar: BottomAppBar(
                shape: const CircularNotchedRectangle(),
                child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(children: [
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            await scripInfo.fetchScripInfo(
                                "${displayData.token}",
                                "${displayData.exch}",
                                context);
                            Navigator.pop(context);

                            Navigator.pushNamed(context, Routes.modifyGtt,
                                arguments: {
                                  "gttOrderBook": displayData,
                                  "scripInfo": ref
                                      .read(marketWatchProvider)
                                      .scripInfoModel!
                                });
                          },
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                                border: Border.all(
                                  color: theme.isDarkMode
                                      ? colors.colorbluegrey
                                      : colors.colorBlack,
                                ),
                                borderRadius: BorderRadius.circular(108)),
                            child: Center(
                              child: TextWidget.subText(text: "Modify Order",theme:theme.isDarkMode,fw: 1),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            ref.read(orderProvider).loading?null:
                            showDialog(
                              context: context,
                              builder: (BuildContext dialogContext) {
                                return AlertDialog(
                                  backgroundColor: theme.isDarkMode
                                      ? const Color.fromARGB(255, 18, 18, 18)
                                      : colors.colorWhite,
                                  titleTextStyle: TextWidget.textStyle(theme: 
                                      theme.isDarkMode,fontSize: 17,fw: 1),
                                  contentTextStyle: TextWidget.textStyle(color: const Color(0XFF666666),fontSize: 14,fw: 0,theme: false),
                                  titlePadding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 10),
                                  shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(14))),
                                  scrollable: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                  ),
                                  insetPadding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  title: Row(
                                    children: [
                                      TextWidget.titleText(text: "${displayData.tsym}",theme:theme.isDarkMode ,fw: 1),
                                      CustomExchBadge(
                                          exch: "${displayData.exch}")
                                    ],
                                  ),
                                  content: SizedBox(
                                    width: MediaQuery.of(dialogContext).size.width,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        TextWidget.titleText(text: "Do you want to Cancel this order?",theme: theme.isDarkMode,fw: 0),
                                      ],
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                        onPressed: () {
                                          Navigator.pop(dialogContext);
                                        },
                                        child: TextWidget.subText(text: "No",theme: false,color: theme.isDarkMode
                                                  ? colors.colorLightBlue
                                                  : colors.colorBlue,fw: 0)),
                                    ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            elevation: 0,
                                            backgroundColor: theme.isDarkMode
                                                ? colors.colorWhite
                                                : colors.colorBlack,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                            )),
                                        onPressed: () async {
                                          Navigator.pop(dialogContext);
                                          await ref
                                              .read(orderProvider)
                                              .cancelGttOrder(
                                                  "${displayData.alId}",
                                                  context);
                                        },
                                        child: TextWidget.subText(text: "Yes",theme:theme.isDarkMode,fw: 0)),
                                  ],
                                );
                              },
                            );
                          },
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                                color: colors.darkred,
                                borderRadius: BorderRadius.circular(108)),
                            child: Center(
                              child: ref.read(orderProvider).loading? 
                                const SizedBox(
                                      width: 18,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Color(0xff666666)),
                                    )
                                  : TextWidget.subText(text: "Cancel Order",theme:theme.isDarkMode,fw: 1),
                            ),
                          ),
                        ),
                      ),
                    ]))));
      },
    );
  }

  Row rowOfInfoData(String title1, String value1, String title2, String value2,
      ThemesProvider theme) {
    return Row(children: [
      Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        TextWidget.paraText(text:title1 ,theme: false, color:const Color(0xff666666),fw: 0),
        const SizedBox(height: 2),
        TextWidget.subText(text:value1 ,theme:theme.isDarkMode,fw: 0),
        const SizedBox(height: 2),
        Divider(
            color: theme.isDarkMode
                ? colors.darkColorDivider
                : colors.colorDivider)
      ])),
      const SizedBox(width: 24),
      Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        TextWidget.paraText(text:title2 ,theme: false, color:const Color(0xff666666),fw: 0),
        const SizedBox(height: 2),
        TextWidget.subText(text:value2 ,theme: theme.isDarkMode,fw: 0),
        const SizedBox(height: 2),
        Divider(
            color: theme.isDarkMode
                ? colors.darkColorDivider
                : colors.colorDivider)
      ]))
    ]);
  }
}
