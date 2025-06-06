import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/order_book_model/gtt_order_book.dart';
import '../../provider/market_watch_provider.dart';
import '../../provider/order_provider.dart';
import '../../provider/thems.dart';
import '../../provider/websocket_provider.dart';
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
                              Text("${displayData.symbol}",
                                  style: textStyles.appBarTitleTxt.copyWith(
                                      color: theme.isDarkMode
                                          ? colors.colorWhite
                                          : colors.colorBlack)),
                              Text(" ${displayData.option} ",
                                  overflow: TextOverflow.ellipsis,
                                  style: textStyles.scripNameTxtStyle.copyWith(
                                      color: theme.isDarkMode
                                          ? colors.colorWhite
                                          : colors.colorBlack)),
                            ],
                          ),
                          Text("₹${displayData.ltp??'0.00'}",
                              style: textStyle(
                                  theme.isDarkMode
                                      ? colors.colorWhite
                                      : colors.colorBlack,
                                  16,
                                  FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(children: [
                              CustomExchBadge(exch: "${displayData.exch}"),
                              Text("  ${displayData.expDate}",
                                  style: textStyle(
                                      theme.isDarkMode
                                          ? colors.colorWhite
                                          : colors.colorBlack,
                                      12,
                                      FontWeight.w600))
                            ]),
                            Text(
                                "${double.parse("${displayData.change ?? 0.00} ").toStringAsFixed(2)} (${displayData.perChange ?? 0.00}%)",
                                style: textStyle(
                                    (displayData.change == "null" ||
                                                displayData.change == null) ||
                                            displayData.change == "0.00"
                                        ? colors.ltpgrey
                                        : displayData.change!.startsWith("-") ||
                                                displayData.perChange!
                                                    .startsWith("-")
                                            ? colors.darkred
                                            : colors.ltpgreen,
                                    12,
                                    FontWeight.w500))
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
                      Text("${ displayData.placeOrderParams?.trantype == 'B' ? 'Buy' : 'Sell'} Trigger @ ${displayData.oivariable?.first.d}",
                          style: textStyle(
                              theme.isDarkMode
                                  ? colors.colorWhite
                                  : colors.colorBlack,
                              16,
                              FontWeight.w600)),
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
                      Text("${ displayData.placeOrderParamsLeg2?.trantype == 'B' ? 'Buy' : 'Sell'} Trigger @ ${displayData.oivariable?.last.d}",
                          style: textStyle(
                              theme.isDarkMode
                                  ? colors.colorWhite
                                  : colors.colorBlack,
                              16,
                              FontWeight.w600)),
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
                      Text("Remarks",
                          style: textStyle(
                              theme.isDarkMode
                                  ? colors.colorWhite
                                  : colors.colorBlack,
                              16,
                              FontWeight.w600)),
                      const SizedBox(height: 16),
                    Text("${displayData.remarks}", style: textStyle(theme.isDarkMode ? colors.colorWhite : colors.colorBlack, 14, FontWeight.w500)),
                    
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
                              child: Text("Modify Order",
                                  style: textStyle(
                                      theme.isDarkMode
                                          ? colors.colorWhite
                                          : colors.colorBlack,
                                      14,
                                      FontWeight.w600)),
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
                                  titleTextStyle: textStyle(
                                      theme.isDarkMode
                                          ? colors.colorWhite
                                          : colors.colorBlack,
                                      17,
                                      FontWeight.w600),
                                  contentTextStyle: textStyle(
                                      const Color(0XFF666666),
                                      14,
                                      FontWeight.w500),
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
                                      Text("${displayData.tsym}"),
                                      CustomExchBadge(
                                          exch: "${displayData.exch}")
                                    ],
                                  ),
                                  content: SizedBox(
                                    width: MediaQuery.of(dialogContext).size.width,
                                    child: const Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            "Do you want to Cancel this order?")
                                      ],
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                        onPressed: () {
                                          Navigator.pop(dialogContext);
                                        },
                                        child: Text(
                                          "No",
                                          style: textStyle(
                                              theme.isDarkMode
                                                  ? colors.colorLightBlue
                                                  : colors.colorBlue,
                                              14,
                                              FontWeight.w500),
                                        )),
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
                                        child: Text(
                                          "Yes",
                                          style: textStyle(
                                              theme.isDarkMode
                                                  ? colors.colorBlack
                                                  : colors.colorWhite,
                                              14,
                                              FontWeight.w500),
                                        )),
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
                                  : 
                              
                              
                              Text("Cancel Order",
                                  style: textStyle(
                                      theme.isDarkMode
                                          ? colors.colorWhite
                                          : colors.colorBlack,
                                      14,
                                      FontWeight.w600)),
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
        Text(title1,
            style: textStyle(const Color(0xff666666), 12, FontWeight.w500)),
        const SizedBox(height: 2),
        Text(value1,
            style: textStyle(
                theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                14,
                FontWeight.w500)),
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
        Text(title2,
            style: textStyle(const Color(0xff666666), 12, FontWeight.w500)),
        const SizedBox(height: 2),
        Text(
          value2,
          style: textStyle(
              theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
              14,
              FontWeight.w500),
        ),
        const SizedBox(height: 2),
        Divider(
            color: theme.isDarkMode
                ? colors.darkColorDivider
                : colors.colorDivider)
      ]))
    ]);
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
        textStyle:
            TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize));
  }
}
