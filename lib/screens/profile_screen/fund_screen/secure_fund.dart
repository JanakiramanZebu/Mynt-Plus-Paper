import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../../provider/fund_provider.dart';
import '../../../provider/thems.dart';
import '../../../res/res.dart';
import '../../../routes/route_names.dart';
import '../../../sharedWidget/custom_back_btn.dart';
import '../../../sharedWidget/custom_widget_button.dart';
import '../../../sharedWidget/functions.dart';

class SecureFund extends ConsumerWidget {
  const SecureFund({super.key});

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final funds = watch(fundProvider);
    final theme = watch(themeProvider);
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
        appBar: AppBar(
          centerTitle: false,
          leadingWidth: 41,
          titleSpacing: 6,
          leading: const CustomBackBtn(),
          elevation: .4,
          title: Text('Funds',
              style: textStyle(
                  theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                  14,
                  FontWeight.w600)),
        ),
        body: ListView(
            padding: const EdgeInsets.symmetric(vertical: 10),
            children: [
              if (funds.fundDetailModel?.avlMrg != "0.00") ...[
                Container(
                    padding: EdgeInsets.zero,
                    margin: EdgeInsets.zero,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: const Color(0xff6eb94b), width: 12)),
                    height: 230,
                    child: SfCircularChart(margin: EdgeInsets.zero, series: [
                      DoughnutSeries<ChartData, String>(
                          radius: "96",
                          dataSource: donutChart,
                          pointColorMapper: (ChartData data, _) => data.color,
                          dataLabelMapper: (ChartData data, _) => "${data.y}%",
                          xValueMapper: (ChartData data, _) => data.x,
                          yValueMapper: (ChartData data, _) => data.y,
                          dataLabelSettings: DataLabelSettings(
                              isVisible: true,
                              textStyle: textStyle(
                                  !theme.isDarkMode
                                      ? colors.colorWhite
                                      : colors.colorBlack,
                                  12,
                                  FontWeight.w600)),
                          innerRadius: "50%")
                    ]))
              ],
              Container(
                  decoration: BoxDecoration(
                      border: Border(
                          bottom: BorderSide(
                              color: theme.isDarkMode
                                  ? colors.darkColorDivider
                                  : colors.colorDivider,
                              width: 6))),
                  padding: const EdgeInsets.all(16),
                  child: Column(children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(children: [
                            const Icon(Icons.circle,
                                color: Color(0xff6eb94b), size: 16),
                            Text(" Credits",
                                style: textStyle(
                                    theme.isDarkMode
                                        ? colors.colorWhite
                                        : colors.colorBlack,
                                    14,
                                    FontWeight.w600))
                          ]),
                          Text(
                              getFormatter(
                                  value: double.parse(
                                      "${funds.fundDetailModel?.totCredit}"),
                                  v4d: false,
                                  noDecimal: false),
                              style: textStyle(
                                  theme.isDarkMode
                                      ? colors.colorWhite
                                      : colors.colorBlack,
                                  14,
                                  FontWeight.w600))
                        ]),
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
                            return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(children: [
                                    Text(
                                        "${funds.listOfCredits[index]["name"]}",
                                        style: textStyle(
                                            const Color(0xff666666),
                                            13,
                                            FontWeight.w500)),
                                    if (funds.listOfCredits[index]["name"] ==
                                        "Broker Collateral")
                                      Padding(
                                          padding:
                                              const EdgeInsets.only(left: 3.0),
                                          child: CustomWidgetButton(
                                              onPress: () async {
                                                await funds
                                                    .fetchHstoken(context);

                                                Navigator.pushNamed(context,
                                                    Routes.reportWebViewApp,
                                                    arguments: "pledge");
                                              },
                                              widget: Row(children: [
                                                Text("   Breakup",
                                                    style: theme.isDarkMode
                                                        ? textStyles.darktextBtn
                                                            .copyWith(
                                                                fontSize: 11)
                                                        : textStyles.textBtn
                                                            .copyWith(
                                                                fontSize: 11)),
                                                Icon(Icons.arrow_drop_down,
                                                    color: !theme.isDarkMode
                                                        ? colors.colorBlue
                                                        : colors.colorLightBlue)
                                              ])))
                                  ]),
                                  Text(
                                      getFormatter(
                                          value: double.parse(
                                              "${funds.listOfCredits[index]["value"]}"),
                                          v4d: false,
                                          noDecimal: false),
                                      style: textStyle(
                                          theme.isDarkMode
                                              ? colors.colorWhite
                                              : colors.colorBlack,
                                          13,
                                          FontWeight.w500))
                                ]);
                          },
                          separatorBuilder: (BuildContext context, int index) {
                            return const SizedBox(height: 8);
                          })
                    ]
                  ])),

              Container(
                  decoration: BoxDecoration(
                      border: Border(
                          bottom: BorderSide(
                              color: theme.isDarkMode
                                  ? colors.darkColorDivider
                                  : colors.colorDivider,
                              width: 6))),
                  padding: const EdgeInsets.all(16),
                  child: Column(children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(children: [
                            Row(children: [
                              Icon(Icons.circle,
                                  color: theme.isDarkMode
                                      ? colors.colorWhite
                                      : colors.colorBlack,
                                  size: 16),
                              Text(" Margin Used ",
                                  style: textStyle(
                                      theme.isDarkMode
                                          ? colors.colorWhite
                                          : colors.colorBlack,
                                      14,
                                      FontWeight.w600))
                            ]),
                            Text(
                                "(${funds.fundDetailModel?.margincurper ?? 0.00}%)",
                                style: textStyle(const Color(0xff666666), 13,
                                    FontWeight.w500))
                          ]),
                          Text(
                              getFormatter(
                                  value: double.parse(
                                      "${funds.fundDetailModel?.utilizedMrgn}"),
                                  v4d: false,
                                  noDecimal: false),
                              style: textStyle(
                                  theme.isDarkMode
                                      ? colors.colorWhite
                                      : colors.colorBlack,
                                  14,
                                  FontWeight.w600))
                        ]),
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
                          return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("${funds.listOfUsedMrgn[index]["name"]}",
                                    style: textStyle(const Color(0xff666666),
                                        12, FontWeight.w500)),
                                Text(
                                    getFormatter(
                                        value: double.parse(
                                            "${funds.listOfUsedMrgn[index]["value"]}"),
                                        v4d: false,
                                        noDecimal: false),
                                    style: textStyle(
                                        theme.isDarkMode
                                            ? colors.colorWhite
                                            : colors.colorBlack,
                                        13,
                                        FontWeight.w500))
                              ]);
                        },
                        separatorBuilder: (BuildContext context, int index) {
                          return const SizedBox(height: 8);
                        },
                      ),
                      Divider(
                          color: theme.isDarkMode
                              ? colors.darkColorDivider
                              : colors.colorDivider,
                          thickness: 2),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Peak Margin",
                                      style: textStyle(const Color(0xff666666),
                                          12, FontWeight.w500)),
                                  const SizedBox(height: 5),
                                  Text(
                                      getFormatter(
                                          value: double.parse(
                                              "${funds.fundDetailModel?.peakMar ?? 0.00}"),
                                          v4d: false,
                                          noDecimal: false),
                                      style: textStyle(
                                          theme.isDarkMode
                                              ? colors.colorWhite
                                              : colors.colorBlack,
                                          14,
                                          FontWeight.w500))
                                ]),
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text("Expiry Margin",
                                      style: textStyle(const Color(0xff666666),
                                          12, FontWeight.w500)),
                                  const SizedBox(height: 5),
                                  Text(
                                      getFormatter(
                                          value: double.parse(
                                              "${funds.fundDetailModel?.expiryMar ?? 0.00}"),
                                          v4d: false,
                                          noDecimal: false),
                                      style: textStyle(
                                          theme.isDarkMode
                                              ? colors.colorWhite
                                              : colors.colorBlack,
                                          14,
                                          FontWeight.w500))
                                ])
                          ])
                    ]
                  ])),

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
                          Text("Open Order Margin",
                              style: textStyle(
                                  theme.isDarkMode
                                      ? colors.colorWhite
                                      : colors.colorBlack,
                                  14,
                                  FontWeight.w600)),
                          Text(
                              getFormatter(
                                  value: double.parse(
                                      "${funds.fundDetailModel!.pendordval ?? 0.00}"),
                                  v4d: false,
                                  noDecimal: false),
                              style: textStyle(
                                  const Color(0xff000000), 14, FontWeight.w600))
                        ])),
              Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(children: [
                          Row(children: [
                            const Icon(Icons.circle,
                                color: Color(0xff015FEC), size: 16),
                            Text(" Available Margin ",
                                style: textStyle(
                                    theme.isDarkMode
                                        ? colors.colorWhite
                                        : colors.colorBlack,
                                    14,
                                    FontWeight.w600))
                          ]),
                          Text(
                              "(${funds.fundDetailModel!.avlMrgPercentage ?? 0.00}%)",
                              style: textStyle(
                                  const Color(0xff666666), 13, FontWeight.w500))
                        ]),
                        Text(
                            getFormatter(
                                value: double.parse(
                                    "${funds.fundDetailModel?.avlMrg}"),
                                v4d: false,
                                noDecimal: false),
                            style: textStyle(
                                theme.isDarkMode
                                    ? colors.colorWhite
                                    : colors.colorBlack,
                                14,
                                FontWeight.w600))
                      ]))
            ]),
        bottomNavigationBar: BottomAppBar(
            child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
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
                                        borderRadius: BorderRadius.circular(50),
                                      )),
                                  onPressed: () async {
                                    await context
                                        .read(fundProvider)
                                        .fetchHstoken(context);
                                    Navigator.pushNamed(
                                        context, Routes.fundTransaction,
                                        arguments: "fund");
                                  },
                                  child: Text("Deposit Money",
                                      textAlign: TextAlign.center,
                                      style: textStyle(
                                          !theme.isDarkMode
                                              ? colors.colorWhite
                                              : colors.colorBlack,
                                          14,
                                          FontWeight.w500))))),
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
                                        borderRadius: BorderRadius.circular(50),
                                      )),
                                  onPressed: () async {
                                    await context
                                        .read(fundProvider)
                                        .fetchHstoken(context);
                                    Navigator.pushNamed(
                                        context, Routes.fundTransaction,
                                        arguments: "withdrawal");
                                  },
                                  child: Text("Withdraw Money",
                                      textAlign: TextAlign.center,
                                      style: textStyle(
                                          !theme.isDarkMode
                                              ? colors.colorWhite
                                              : colors.colorBlack,
                                          14,
                                          FontWeight.w500)))))
                    ]))));
  }

  Row rowOfInfoData(
      String title1, String value1, String title2, String value2) {
    return Row(children: [
      Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title1,
            style: textStyle(const Color(0xff666666), 12, FontWeight.w500)),
        const SizedBox(height: 3),
        Text(value1,
            style: textStyle(const Color(0xff000000), 14, FontWeight.w500)),
        const SizedBox(height: 2),
        Divider(color: colors.colorDivider)
      ])),
      const SizedBox(width: 24),
      Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title2,
            style: textStyle(const Color(0xff666666), 12, FontWeight.w500)),
        const SizedBox(height: 3),
        Text(
          value2,
          style: textStyle(const Color(0xff000000), 14, FontWeight.w500),
        ),
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
