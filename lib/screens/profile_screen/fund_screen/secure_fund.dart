import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../../provider/fund_provider.dart';
import '../../../provider/thems.dart';
import '../../../provider/transcation_provider.dart';
import '../../../res/global_state_text.dart';
import '../../../res/res.dart';
import '../../../routes/route_names.dart';
import '../../../sharedWidget/custom_widget_button.dart';
import '../../../sharedWidget/functions.dart';

class SecureFund extends ConsumerWidget {
  const SecureFund({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final funds = ref.watch(fundProvider);
    final theme = ref.watch(themeProvider);
    final trancation = ref.watch(transcationProvider);
    // Preferences pref = Preferences();
    final List<ChartData> donutChart = [
      if (funds.fundDetailModel?.margincurper != null)
        ChartData(
            'Margin Used',
            double.parse("${funds.fundDetailModel?.margincurper ?? 0.00}"),
            theme.isDarkMode ? const Color(0xffEEEEEE) : colors.colorBlack),
      ChartData(
          'Avialable Margin',
          double.parse("${funds.fundDetailModel?.avlMrgPercentage ?? 0.00}"),
          const Color(0xff015FEC))
    ];

    return Scaffold(
      // appBar: AppBar(
      //   centerTitle: false,
      //   leadingWidth: 41,
      //   titleSpacing: 6,
      //   leading: const CustomBackBtn(),
      //   elevation: .4,
      //   title: Text('Funds',
      //       style: textStyle(
      //           theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
      //           14,
      //           FontWeight.w600)),
      //   actions: [
      //     Padding(
      //       padding: const EdgeInsets.only(top: 22, right: 16),
      //       child: InkWell(
      //         onTap: () async {
      //           await funds.fetchHstoken(context);
      //           Future.delayed(Duration(microseconds: 10), () {
      //             launch(
      //                 'https://fund.mynt.in/fund/?sAccountId=${pref.clientId}&sToken=${funds.fundHstoken!.hstk}&src=app');
      //           });
      //         },
      //         child: Text(
      //           "Web",
      //           style: textStyle(colors.colorBlue, 14, FontWeight.w600),
      //         ),
      //       ),
      //     )
      //   ],
      // ),
      body: ListView(
          // padding: const EdgeInsets.symmetric(vertical: 10),
          children: [
            // if (funds.fundDetailModel?.avlMrg != "0.00") ...[
            //   const SizedBox(height: 16),
            //   Container(
            //       padding: EdgeInsets.zero,
            //       margin: EdgeInsets.zero,
            //       decoration: BoxDecoration(
            //           shape: BoxShape.circle,
            //           border: Border.all(
            //               color: const Color(0xff6eb94b), width: 12)),
            //       height: 230,
            //       child: SfCircularChart(margin: EdgeInsets.zero, series: [
            //         DoughnutSeries<ChartData, String>(
            //             radius: "96",
            //             dataSource: donutChart,
            //             pointColorMapper: (ChartData data, _) => data.color,
            //             dataLabelMapper: (ChartData data, _) => "${data.y}%",
            //             xValueMapper: (ChartData data, _) => data.x,
            //             yValueMapper: (ChartData data, _) => data.y,
            //             dataLabelSettings: DataLabelSettings(
            //                 isVisible: true,
            //                 textStyle: TextWidget.textStyle(
            //                     theme: false,
            //                     color: !theme.isDarkMode
            //                         ? colors.colorWhite
            //                         : colors.colorBlack,
            //                     fontSize: 12,
            //                     fw: 1)),
            //             innerRadius: "50%")
            //       ]))
            // ],
            Container(
              color: const Color(0xFFF1F3F8),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 8),
                      decoration: BoxDecoration(
                        color: colors.colorWhite,
                        // color: theme.isDarkMode
                        //     ? const Color(0xffB5C0CF).withOpacity(.15)
                        //     : const Color(0xffF1F3F8),
                        border: Border.all(
                            color: theme.isDarkMode
                                ? colors.darkColorDivider
                                : colors.colorDivider,
                            width: 1),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(4)),
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Available Margin",
                                    style: TextWidget.textStyle(
                                        fontSize: 13,
                                        theme: theme.isDarkMode,
                                        color: theme.isDarkMode
                                            ? colors.colorWhite
                                            : colors.colorGrey,
                                        fw: 0)),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    TextWidget.titleText(
                                        text: getFormatter(
                                            value: double.parse(
                                                "${funds.fundDetailModel?.avlMrg}"),
                                            v4d: false,
                                            noDecimal: false),
                                        theme: theme.isDarkMode,
                                        fw: 0),
                                    // const SizedBox(
                                    //   height: 4,
                                    // ),
                                    // TextWidget.paraText(
                                    //     text:
                                    //         "${funds.fundDetailModel!.avlMrgPercentage ?? 0.00}%",
                                    //     theme: false,
                                    //     color: const Color(0xff666666),
                                    //     fw: 0),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Divider(color: colors.colorDivider, height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Credits",
                                        style: TextWidget.textStyle(
                                            fontSize: 13,
                                            theme: theme.isDarkMode,
                                            color: theme.isDarkMode
                                                ? colors.colorWhite
                                                : colors.colorGrey,
                                            fw: 0)),
                                    const SizedBox(
                                      height: 4,
                                    ),
                                    TextWidget.subText(
                                        text: getFormatter(
                                            value: double.parse(
                                                "${funds.fundDetailModel?.totCredit}"),
                                            v4d: false,
                                            noDecimal: false),
                                        theme: theme.isDarkMode,
                                        fw: 0),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text("Margin Used",
                                        style: TextWidget.textStyle(
                                            fontSize: 13,
                                            theme: theme.isDarkMode,
                                            color: theme.isDarkMode
                                                ? colors.colorWhite
                                                : colors.colorGrey,
                                            fw: 0)),
                                    const SizedBox(
                                      height: 4,
                                    ),
                                    TextWidget.subText(
                                        text: getFormatter(
                                            value: double.parse(
                                                "${funds.fundDetailModel?.utilizedMrgn}"),
                                            v4d: false,
                                            noDecimal: false),
                                        theme: theme.isDarkMode,
                                        fw: 0),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // const SizedBox(
                  //   height: 10,
                  // ),
                  Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 16),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                                child: SizedBox(
                                    height: 40,
                                    child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            elevation: 0,
                                            shadowColor: Colors.transparent,
                                            backgroundColor: theme.isDarkMode
                                                ? colors.colorbluegrey
                                                : colors.colorBlack,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                            )),
                                        onPressed: () async {
                                          await trancation
                                              .fetchValidateToken(context);
                                          Future.delayed(
                                              const Duration(milliseconds: 100),
                                              () async {
                                            await trancation.ip();
                                            await trancation.fetchupiIdView(
                                                trancation.bankdetails!.dATA![
                                                    trancation.indexss][1],
                                                trancation.bankdetails!.dATA![
                                                    trancation.indexss][2]);

                                            await trancation
                                                .fetchcwithdraw(context);
                                          });
                                          trancation.changebool(true);
                                          Navigator.pushNamed(
                                              context, Routes.fundscreen,
                                              arguments: trancation);
                                        },
                                        child: TextWidget.subText(
                                            text: "Deposit Money",
                                            theme: !theme.isDarkMode,
                                            fw: 0,
                                            align: TextAlign.center)))),
                            const SizedBox(width: 12),
                            Expanded(
                                child: SizedBox(
                                    height: 40,
                                    child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            elevation: 0,
                                            shadowColor: Colors.transparent,
                                            backgroundColor: theme.isDarkMode
                                                ? colors.colorbluegrey
                                                : colors.colorBlack,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                            )),
                                        onPressed: () async {
                                          await trancation
                                              .fetchValidateToken(context);
                                          Future.delayed(
                                              const Duration(milliseconds: 100),
                                              () async {
                                            await trancation.ip();
                                            await trancation.fetchupiIdView(
                                                trancation.bankdetails!.dATA![
                                                    trancation.indexss][1],
                                                trancation.bankdetails!.dATA![
                                                    trancation.indexss][2]);

                                            await trancation
                                                .fetchcwithdraw(context);
                                          });
                                          trancation.changebool(false);
                                          Navigator.pushNamed(
                                              context, Routes.fundscreen,
                                              arguments: trancation);
                                        },
                                        child: TextWidget.subText(
                                            text: "Withdraw Money",
                                            theme: !theme.isDarkMode,
                                            fw: 0,
                                            align: TextAlign.center))))
                          ])),
                ],
              ),
            ),

            // const SizedBox(height: 15),
            funds.listOfCredits.isNotEmpty
                ? Container(
                    decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(
                                color: theme.isDarkMode
                                    ? colors.darkColorDivider
                                    : colors.colorDivider,
                                width: 6))),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextWidget.subText(
                              text: "Credits", theme: theme.isDarkMode, fw: 1),
                          // Row(
                          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //     children: [

                          // Row(children: [
                          //   const Icon(Icons.circle,
                          //       color: Color(0xff6eb94b), size: 16),

                          // ]),
                          // TextWidget.subText(
                          //     text: getFormatter(
                          //         value: double.parse(
                          //             "${funds.fundDetailModel?.totCredit}"),
                          //         v4d: false,
                          //         noDecimal: false),
                          //     theme: theme.isDarkMode,
                          //     fw: 1),
                          // ]),
                          if (funds.listOfCredits.isNotEmpty) ...[
                            Divider(
                                color: theme.isDarkMode
                                    ? colors.darkColorDivider
                                    : colors.colorDivider,
                                thickness: 1.2),
                            ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: funds.listOfCredits.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return Column(
                                    children: [
                                      const SizedBox(height: 10),
                                      Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(children: [
                                              Text(
                                                  "${funds.listOfCredits[index]["name"]}",
                                                  style: TextWidget.textStyle(
                                                    fontSize: 14,
                                                    theme: theme.isDarkMode,
                                                    color: theme.isDarkMode
                                                        ? colors.colorWhite
                                                        : colors.colorGrey,
                                                    // color: const Color(0xff666666),
                                                  )),
                                              if (funds.listOfCredits[index]
                                                      ["name"] ==
                                                  "Collateral")
                                                Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 4.0),
                                                    child: CustomWidgetButton(
                                                        onPress: () async {
                                                          await funds
                                                              .fetchHstoken(
                                                                  context);

                                                          Navigator.pushNamed(
                                                              context,
                                                              Routes
                                                                  .reportWebViewApp,
                                                              arguments:
                                                                  "pledge");
                                                        },
                                                        widget: Row(children: [
                                                          TextWidget.captionText(
                                                              text: "Breakup",
                                                              theme: false,
                                                              color: theme.isDarkMode
                                                                  ? colors
                                                                      .colorLightBlue
                                                                  : colors
                                                                      .colorBlue,
                                                              fw: 0),
                                                          Icon(
                                                            Icons
                                                                .arrow_drop_down,
                                                            color: !theme
                                                                    .isDarkMode
                                                                ? colors
                                                                    .colorBlue
                                                                : colors
                                                                    .colorLightBlue,
                                                            size: 20,
                                                          )
                                                        ])))
                                            ]),
                                            TextWidget.subText(
                                                text: getFormatter(
                                                    value: double.parse(
                                                        "${funds.listOfCredits[index]["value"]}"),
                                                    v4d: false,
                                                    noDecimal: false),
                                                theme: theme.isDarkMode,
                                                fw: 0),
                                          ]),
                                    ],
                                  );
                                },
                                separatorBuilder:
                                    (BuildContext context, int index) {
                                  return Divider(
                                    color: theme.isDarkMode
                                        ? colors.darkColorDivider
                                        : colors.colorDivider,
                                  );
                                })
                          ]
                        ]))
                : const SizedBox(),

            funds.listOfUsedMrgn.isNotEmpty
                ? Container(
                    decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(
                                color: theme.isDarkMode
                                    ? colors.darkColorDivider
                                    : colors.colorDivider,
                                width: 6))),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextWidget.subText(
                              text: "Margin Used",
                              theme: theme.isDarkMode,
                              fw: 1),
                          // Row(
                          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //     children: [
                          //       Row(children: [
                          //         Row(children: [
                          //           Icon(Icons.circle,
                          //               color: theme.isDarkMode
                          //                   ? colors.colorWhite
                          //                   : colors.colorBlack,
                          //               size: 16),

                          //         ]),
                          //         TextWidget.paraText(
                          //             text:
                          //                 "(${funds.fundDetailModel?.margincurper ?? 0.00}%)",
                          //             theme: false,
                          //             color: const Color(0xff666666),
                          //             fw: 0),
                          //       ]),
                          //       TextWidget.subText(
                          //           text: getFormatter(
                          //               value: double.parse(
                          //                   "${funds.fundDetailModel?.utilizedMrgn}"),
                          //               v4d: false,
                          //               noDecimal: false),
                          //           theme: theme.isDarkMode,
                          //           fw: 1),
                          //     ]),
                          if (funds.listOfUsedMrgn.isNotEmpty) ...[
                            Divider(
                                color: theme.isDarkMode
                                    ? colors.darkColorDivider
                                    : colors.colorDivider,
                                thickness: 1.2),
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: funds.listOfUsedMrgn.length,
                              itemBuilder: (BuildContext context, int index) {
                                return Column(
                                  children: [
                                    const SizedBox(height: 10),
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                              "${funds.listOfUsedMrgn[index]["name"]}",
                                              style: TextWidget.textStyle(
                                                fontSize: 14,
                                                theme: theme.isDarkMode,
                                                color: theme.isDarkMode
                                                    ? colors.colorWhite
                                                    : colors.colorGrey,
                                                // color: const Color(0xff666666),
                                              )),
                                          TextWidget.subText(
                                              text: getFormatter(
                                                  value: double.parse(
                                                      "${funds.listOfUsedMrgn[index]["value"]}"),
                                                  v4d: false,
                                                  noDecimal: false),
                                              theme: theme.isDarkMode,
                                              fw: 0),
                                        ]),
                                  ],
                                );
                              },
                              separatorBuilder:
                                  (BuildContext context, int index) {
                                return Divider(
                                  color: theme.isDarkMode
                                      ? colors.darkColorDivider
                                      : colors.colorDivider,
                                );
                              },
                            ),
                            // Divider(
                            //     color: theme.isDarkMode
                            //         ? colors.darkColorDivider
                            //         : colors.colorDivider,
                            //     thickness: 2),
                            // const SizedBox(height: 6),
                            Divider(
                              color: theme.isDarkMode
                                  ? colors.darkColorDivider
                                  : colors.colorDivider,
                            ),
                            const SizedBox(height: 10),
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Peak Margin",
                                      style: TextWidget.textStyle(
                                        fontSize: 14,
                                        theme: theme.isDarkMode,
                                        color: theme.isDarkMode
                                            ? colors.colorWhite
                                            : colors.colorGrey,
                                        // color: const Color(0xff666666),
                                      )),
                                  const SizedBox(height: 6),
                                  TextWidget.subText(
                                      text: getFormatter(
                                          value: double.parse(
                                              "${funds.fundDetailModel?.peakMar ?? 0.00}"),
                                          v4d: false,
                                          noDecimal: false),
                                      theme: theme.isDarkMode,
                                      fw: 0),
                                ]),
                            Divider(
                              color: theme.isDarkMode
                                  ? colors.darkColorDivider
                                  : colors.colorDivider,
                            ),
                            const SizedBox(height: 10),
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Expiry Margin",
                                      style: TextWidget.textStyle(
                                        fontSize: 14,
                                        theme: theme.isDarkMode,
                                        color: theme.isDarkMode
                                            ? colors.colorWhite
                                            : colors.colorGrey,
                                        // color: const Color(0xff666666),
                                      )),
                                  const SizedBox(height: 6),
                                  TextWidget.subText(
                                      text: getFormatter(
                                          value: double.parse(
                                              "${funds.fundDetailModel?.expiryMar ?? 0.00}"),
                                          v4d: false,
                                          noDecimal: false),
                                      theme: theme.isDarkMode,
                                      fw: 0),
                                ])
                          ]
                        ]))
                : const SizedBox(),

            // rowOfInfoData(
            //     "Peak Margin",
            //     "${getFormatter(value: double.parse("${funds.fundDetailModel?.peakMar ?? 0.00}"), v4d: false, noDecimal: false)}",
            //     "Expiry Margin",
            //     "${getFormatter(value: double.parse("${funds.fundDetailModel?.expiryMar ?? 0.00}"), v4d: false, noDecimal: false)}"),
            if (funds.fundDetailModel!.pendordval != null)
              Container(
                  decoration: BoxDecoration(
                      border: Border(
                          bottom: BorderSide(
                              color: theme.isDarkMode
                                  ? colors.darkGrey
                                  : const Color(0xffF1F3F8),
                              width: 6))),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextWidget.subText(
                            text: "Open Order Margin",
                            theme: theme.isDarkMode,
                            fw: 1),
                        TextWidget.subText(
                            text: getFormatter(
                                value: double.parse(
                                    "${funds.fundDetailModel!.pendordval ?? 0.00}"),
                                v4d: false,
                                noDecimal: false),
                            theme: theme.isDarkMode,
                            color: const Color(0xff000000),
                            fw: 1),
                      ])),
            // Container(
            //     padding: const EdgeInsets.all(16),
            //     child: Row(
            //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //         children: [
            //           Row(children: [
            //             Row(children: [
            //               const Icon(Icons.circle,
            //                   color: Color(0xff015FEC), size: 16),
            //               TextWidget.subText(
            //                   text: " Available Margin ",
            //                   theme: theme.isDarkMode,
            //                   fw: 1),
            //             ]),
            //             TextWidget.paraText(
            //                 text:
            //                     "(${funds.fundDetailModel!.avlMrgPercentage ?? 0.00}%)",
            //                 theme: false,
            //                 color: const Color(0xff666666),
            //                 fw: 0),
            //           ]),
            //           TextWidget.subText(
            //               text: getFormatter(
            //                   value: double.parse(
            //                       "${funds.fundDetailModel?.avlMrg}"),
            //                   v4d: false,
            //                   noDecimal: false),
            //               theme: theme.isDarkMode,
            //               fw: 1),
            //         ]))
          ]),
      // bottomNavigationBar: BottomAppBar(
      //     child:)
    );
  }

  Row rowOfInfoData(
      String title1, String value1, String title2, String value2) {
    return Row(children: [
      Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        TextWidget.paraText(
            text: title1, theme: false, color: const Color(0xff666666), fw: 0),
        const SizedBox(height: 3),
        TextWidget.subText(
            text: value1, theme: false, color: const Color(0xff000000), fw: 0),
        const SizedBox(height: 2),
        Divider(color: colors.colorDivider)
      ])),
      const SizedBox(width: 24),
      Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        TextWidget.paraText(
            text: title2, theme: false, color: const Color(0xff666666), fw: 0),
        const SizedBox(height: 3),
        TextWidget.subText(
            text: value2, theme: false, color: const Color(0xff000000), fw: 0),
        const SizedBox(height: 2),
        Divider(color: colors.colorDivider)
      ]))
    ]);
  }
}

class ChartData {
  ChartData(this.x, this.y, this.color);
  final String x;
  final double y;
  final Color color;
}
