import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../provider/order_provider.dart';
import '../../provider/thems.dart';
import '../../res/res.dart';
import '../../sharedWidget/custom_drag_handler.dart';

class MarginDetailsBottomsheet extends StatefulWidget {
  const MarginDetailsBottomsheet({super.key});

  @override
  State<MarginDetailsBottomsheet> createState() =>
      _MarginDetailsBottomsheetState();
}

class _MarginDetailsBottomsheetState extends State<MarginDetailsBottomsheet> {
  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, WidgetRef ref, _) {
      final orderMargin = ref.watch(orderProvider).orderMarginModel;
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15.0, vertical: 0),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Order Margin",
                              style: textStyles.appBarTitleTxt.copyWith(
                                  color: !theme.isDarkMode
                                      ? colors.colorBlack
                                      : colors.colorWhite))
                        ])),
                Divider(
                    color: theme.isDarkMode
                        ? colors.darkColorDivider
                        : colors.colorDivider),
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Column(children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Cash",
                              style: textStyle(
                                  !theme.isDarkMode
                                      ? colors.colorBlack
                                      : colors.colorWhite,
                                  14,
                                  FontWeight.w500)),
                          Text("${orderMargin!.cash}",
                              style: textStyle(
                                  !theme.isDarkMode
                                      ? colors.colorBlack
                                      : colors.colorWhite,
                                  14,
                                  FontWeight.w500))
                        ],
                      ),
                      Divider(
                          color: theme.isDarkMode
                              ? colors.darkColorDivider
                              : colors.colorDivider,
                          height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Margin used",
                              style: textStyle(
                                  !theme.isDarkMode
                                      ? colors.colorBlack
                                      : colors.colorWhite,
                                  14,
                                  FontWeight.w500)),
                          Text("${orderMargin.marginused}",
                              style: textStyle( 
                                      orderMargin.remarks ==
                                              "Insufficient Balance"
                                          ? colors.darkred
                                          : 
                                  !theme.isDarkMode
                                      ? colors.colorBlack
                                      : colors.colorWhite,
                                  14,
                                  FontWeight.w500))
                        ],
                      ),
                      Divider(
                          color: theme.isDarkMode
                              ? colors.darkColorDivider
                              : colors.colorDivider,
                          height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Margin used previous",
                              style: textStyle(
                                  !theme.isDarkMode
                                      ? colors.colorBlack
                                      : colors.colorWhite,
                                  14,
                                  FontWeight.w500)),
                          Text("${orderMargin.marginusedprev}",
                              style: textStyle(
                                  !theme.isDarkMode
                                      ? colors.colorBlack
                                      : colors.colorWhite,
                                  14,
                                  FontWeight.w500))
                        ],
                      ),
                      Divider(
                          color: theme.isDarkMode
                              ? colors.darkColorDivider
                              : colors.colorDivider,
                          height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Order Margin",
                              style: textStyle(
                                  !theme.isDarkMode
                                      ? colors.colorBlack
                                      : colors.colorWhite,
                                  14,
                                  FontWeight.w500)),
                          Text("${orderMargin.ordermargin}",
                              style: textStyle(
                                  !theme.isDarkMode
                                      ? colors.colorBlack
                                      : colors.colorWhite,
                                  14,
                                  FontWeight.w500))
                        ],
                      ),
                      if (orderMargin.remarks != null) ...[
                        Divider(
                            color: theme.isDarkMode
                                ? colors.darkColorDivider
                                : colors.colorDivider,
                            height: 20),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Remarks - ",
                                  style: textStyle(
                                      !theme.isDarkMode
                                          ? colors.colorBlack
                                          : colors.colorWhite,
                                      14,
                                      FontWeight.w500)),
                              Text("${orderMargin.remarks}",
                                  style: textStyle(
                                      orderMargin.remarks ==
                                              "Insufficient Balance"
                                          ? colors.darkred
                                          : colors.ltpgreen,
                                      14,
                                      FontWeight.w500))
                            ])
                      ],
                      const SizedBox(height: 16)
                    ]))
              ]));
    });
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
        textStyle:
            TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize));
  }
}

class ChargesDetailsBottomsheet extends StatefulWidget {
  const ChargesDetailsBottomsheet({super.key});

  @override
  State<ChargesDetailsBottomsheet> createState() =>
      _ChargesDetailsBottomsheetState();
}

class _ChargesDetailsBottomsheetState extends State<ChargesDetailsBottomsheet> {
  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, WidgetRef ref, _) {
      final orderBrokerage = ref.watch(orderProvider).getBrokerageModel;
      final orderProvide = ref.watch(orderProvider);
      final theme = ref.watch(themeProvider);
      return orderProvide.getBrokerageModel!.emsg ==
              "Error Occurred : Invalid order details/brokerage plan not set"
          ? Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: theme.isDarkMode ? Colors.black : Colors.white,
                  boxShadow: const [
                    BoxShadow(
                        color: Color(0xff999999),
                        blurRadius: 4.0,
                        offset: Offset(2.0, 0.0))
                  ]),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CustomDragHandler(),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      //mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                            "Get update your brokerage details. Reach out our support",
                            textAlign: TextAlign.center,
                            style: textStyle(
                                !theme.isDarkMode
                                    ? colors.colorBlack
                                    : colors.colorWhite,
                                16,
                                FontWeight.w500)),
                        SizedBox(
                          height: 10,
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: ElevatedButton(
                              onPressed: () async {
                                final Uri url =
                                    Uri(scheme: 'tel', path: "9380108010");
                                await launchUrl(url);
                              },
                              style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  backgroundColor: !theme.isDarkMode
                                      ? colors.colorBlack
                                      : colors.colorWhite,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 13),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  )),
                              child: Text("Call now",
                                  style: textStyles.btnText.copyWith(
                                      color: theme.isDarkMode
                                          ? colors.colorBlack
                                          : colors.colorWhite))),
                        ),
                      ],
                    ),
                  ),
                ],
              ))
          : Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: theme.isDarkMode ? Colors.black : Colors.white,
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15.0, vertical: 0),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Charges and Taxes",
                                  style: textStyles.appBarTitleTxt.copyWith(
                                    color: !theme.isDarkMode
                                        ? colors.colorBlack
                                        : colors.colorWhite,
                                  ))
                            ])),
                    Divider(
                        color: theme.isDarkMode
                            ? colors.darkColorDivider
                            : colors.colorDivider),
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Column(children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Brokerage Amt",
                                  style: textStyle(
                                      !theme.isDarkMode
                                          ? colors.colorBlack
                                          : colors.colorWhite,
                                      14,
                                      FontWeight.w500)),
                              Text("${orderBrokerage?.brkageAmt}",
                                  style: textStyle(
                                      !theme.isDarkMode
                                          ? colors.colorBlack
                                          : colors.colorWhite,
                                      14,
                                      FontWeight.w500))
                            ],
                          ),
                          Divider(
                              color: theme.isDarkMode
                                  ? colors.darkColorDivider
                                  : colors.colorDivider,
                              height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("STT total",
                                  style: textStyle(
                                      !theme.isDarkMode
                                          ? colors.colorBlack
                                          : colors.colorWhite,
                                      14,
                                      FontWeight.w500)),
                              Text("${orderBrokerage?.sttAmt}",
                                  style: textStyle(
                                      !theme.isDarkMode
                                          ? colors.colorBlack
                                          : colors.colorWhite,
                                      14,
                                      FontWeight.w500))
                            ],
                          ),
                          Divider(
                              color: theme.isDarkMode
                                  ? colors.darkColorDivider
                                  : colors.colorDivider,
                              height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Exchange charges",
                                  style: textStyle(
                                      !theme.isDarkMode
                                          ? colors.colorBlack
                                          : colors.colorWhite,
                                      14,
                                      FontWeight.w500)),
                              Text("${orderBrokerage?.exchChrg}",
                                  style: textStyle(
                                      !theme.isDarkMode
                                          ? colors.colorBlack
                                          : colors.colorWhite,
                                      14,
                                      FontWeight.w500))
                            ],
                          ),
                          Divider(
                              color: theme.isDarkMode
                                  ? colors.darkColorDivider
                                  : colors.colorDivider,
                              height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("SEBI charges",
                                  style: textStyle(
                                      !theme.isDarkMode
                                          ? colors.colorBlack
                                          : colors.colorWhite,
                                      14,
                                      FontWeight.w500)),
                              Text("${orderBrokerage?.sebiChrg}",
                                  style: textStyle(
                                      !theme.isDarkMode
                                          ? colors.colorBlack
                                          : colors.colorWhite,
                                      14,
                                      FontWeight.w500))
                            ],
                          ),
                          Divider(
                              color: theme.isDarkMode
                                  ? colors.darkColorDivider
                                  : colors.colorDivider,
                              height: 20),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Stamp duty",
                                    style: textStyle(
                                        !theme.isDarkMode
                                            ? colors.colorBlack
                                            : colors.colorWhite,
                                        14,
                                        FontWeight.w500)),
                                Text("${orderBrokerage?.stampDuty}",
                                    style: textStyle(
                                        !theme.isDarkMode
                                            ? colors.colorBlack
                                            : colors.colorWhite,
                                        14,
                                        FontWeight.w500))
                              ]),
                          Divider(
                              color: theme.isDarkMode
                                  ? colors.darkColorDivider
                                  : colors.colorDivider,
                              height: 20),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Clearing charges",
                                    style: textStyle(
                                        !theme.isDarkMode
                                            ? colors.colorBlack
                                            : colors.colorWhite,
                                        14,
                                        FontWeight.w500)),
                                Text("${orderBrokerage?.clrChrg}",
                                    style: textStyle(
                                        !theme.isDarkMode
                                            ? colors.colorBlack
                                            : colors.colorWhite,
                                        14,
                                        FontWeight.w500))
                              ]),
                          Divider(
                              color: theme.isDarkMode
                                  ? colors.darkColorDivider
                                  : colors.colorDivider,
                              height: 20),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("GST",
                                    style: textStyle(
                                        !theme.isDarkMode
                                            ? colors.colorBlack
                                            : colors.colorWhite,
                                        14,
                                        FontWeight.w500)),
                                Text("${orderBrokerage?.gst}",
                                    style: textStyle(
                                        !theme.isDarkMode
                                            ? colors.colorBlack
                                            : colors.colorWhite,
                                        14,
                                        FontWeight.w500))
                              ]),
                          const SizedBox(height: 10)
                        ]))
                  ]));
    });
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
        textStyle:
            TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize));
  }
}
